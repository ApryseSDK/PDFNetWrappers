var origin  = window.location.origin;
var p = origin.indexOf('pdftron.com') > -1;

(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

ga('create', p ? 'UA-6566170-1' : 'UA-6566170-2', 'auto');

ga(function (tracker) {
  var clientID = tracker.get('clientId');
  var sessionId = new Date().getTime() + '.' + Math.random().toString(36).substring(5);
  var trialTS = localStorage.getItem('@pdftron-trial-start');
  var key = localStorage.getItem('@pdftron_license_key');

  ga('set', 'dimension1', clientID);
  ga('set', 'dimension2', sessionId);
  ga('set', 'dimension3', new Date().getTime().toString());

  if (trialTS) {
    ga('set', 'dimension4', trialTS);
  }

  if (key) {
    ga('set', 'dimension6', key);
  }

  
  ga('send', 'pageview');
})