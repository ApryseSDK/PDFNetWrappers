/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * Typemaps for std::string and const std::string&
 * These are mapped to an PHP array 
 *
 * To use non-const std::string references use the following %apply.
 * %apply const std::string & {std::string &};
 * ----------------------------------------------------------------------------- */

%{
#include <string>
%}

%typemap(in) std::vector<std::string> 
{
      HashTable *arr_hash;
      HashPosition pointer;
      int array_count;
      int i$argnum = 0;
      std::vector<std::string>vec;
#if PHP_MAJOR_VERSION >= 7
      zval *data;
      arr_hash = Z_ARRVAL_P(&$input);
      array_count = zend_hash_num_elements(arr_hash);
      vec.resize(array_count);
      for(zend_hash_internal_pointer_reset_ex(arr_hash,&pointer);
          (data = zend_hash_get_current_data_ex(arr_hash,&pointer)) != NULL && i$argnum < array_count;
          zend_hash_move_forward_ex(arr_hash,&pointer)
         )
      {
          if(Z_TYPE_P(data) == IS_STRING){
              vec[i$argnum] = std::string(Z_STRVAL_P(data));
          }
          else{
              zend_error(E_ERROR, "Expected a string.");
          }
          i$argnum++;
      }

#else	  
      // PHP 5
      zval **data;
      arr_hash = Z_ARRVAL_PP($input);
      array_count = zend_hash_num_elements(arr_hash);
      vec.resize(array_count);
      for(zend_hash_internal_pointer_reset_ex(arr_hash,&pointer);
          zend_hash_get_current_data_ex(arr_hash,(void**)&data,&pointer) == SUCCESS && i$argnum < array_count;
          zend_hash_move_forward_ex(arr_hash,&pointer)
         )
      {
          if(Z_TYPE_PP(data) == IS_STRING){
              vec[i$argnum] = std::string(Z_STRVAL_PP(data));
          }
          else{
              zend_error(E_ERROR, "Expected a string.");
          }
          i$argnum++;
     }
#endif
      $1 = vec;
}


%typemap(in) std::vector<std::string>& 
{
      HashTable *arr_hash;
      HashPosition pointer;
      int array_count;
      int i$argnum = 0;
      std::vector<std::string>* vec = $1;
       
#if PHP_MAJOR_VERSION >= 7
      zval *data;
      arr_hash = Z_ARRVAL_P(&$input);
      array_count = zend_hash_num_elements(arr_hash);
      if (vec == NULL) {
        vec = new std::vector<std::string>;
      }
      vec->resize(array_count);
      
      for(zend_hash_internal_pointer_reset_ex(arr_hash,&pointer);
          (data = zend_hash_get_current_data_ex(arr_hash,&pointer)) != NULL && i$argnum < array_count;
          zend_hash_move_forward_ex(arr_hash,&pointer)
         )
      {
          if(Z_TYPE_P(data) == IS_STRING){
              (*vec)[i$argnum] = std::string(Z_STRVAL_P(data));
          }
          else{
              zend_error(E_ERROR, "Expected a string.");
          }
          i$argnum++;
      }

#else	  
      // PHP 5
      zval **data;
      arr_hash = Z_ARRVAL_PP($input);
      array_count = zend_hash_num_elements(arr_hash);
      if (vec == NULL) {
        vec = new std::vector<std::string>;
      }
      vec->resize(array_count);

      for(zend_hash_internal_pointer_reset_ex(arr_hash,&pointer);
          zend_hash_get_current_data_ex(arr_hash,(void**)&data,&pointer) == SUCCESS && i$argnum < array_count;
          zend_hash_move_forward_ex(arr_hash,&pointer)
         )
      {
          if(Z_TYPE_PP(data) == IS_STRING){
             (*vec)[i$argnum] = std::string(Z_STRVAL_PP(data));
          }
          else{
              zend_error(E_ERROR, "Expected a string.");
          }
	  i$argnum++;
     }
#endif
  $1 = vec;
}


%typemap(out) std::vector<std::string>
{
    array_init($result);
    $1_type::const_iterator i = $1.begin();
    $1_type::const_iterator e = $1.end();

    for(; i != e; ++i )
    {
#if PHP_MAJOR_VERSION >= 7    
        add_next_index_string($result, (char*) i->c_str() );
#else
        zval * data;
        MAKE_STD_ZVAL(data);
        ZVAL_STRINGL(data, (char*)i->c_str(), i->size(), 1);
        zend_hash_next_index_insert( HASH_OF($result), &data, sizeof(zval *), NULL );
#endif 
    }
}


%typemap(typecheck) std::vector<std::string>, std::vector<std::string>&
{
#if PHP_MAJOR_VERSION >= 7
    $1 = ( Z_TYPE_P(&$input) == IS_ARRAY ) ? 1 : 0;
#else
    $1 = ( Z_TYPE_PP($input) == IS_ARRAY ) ? 1 : 0;
#endif
}

%typemap(freearg) std::vector<std::string>&
%{
    delete ($1);
%}

