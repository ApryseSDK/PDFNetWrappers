#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2019 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

from shutil import copyfile
import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

# Relative path to the folder containing test files.
input_path =  "../../TestFiles/"
output_path = "../../TestFiles/Output/"

#---------------------------------------------------------------------------------------
# The following sample illustrates how to use the UndoRedo API.
#---------------------------------------------------------------------------------------

def main():
	# The first step in every application using PDFNet is to initialize the 
	# library and set the path to common PDF resources. The library is usually 
	# initialized only once, but calling Initialize() multiple times is also fine.
	PDFNet.Initialize()
	
	# Open the PDF document.
	doc = PDFDoc(input_path + "newsletter.pdf")

	# Save to a different file, so that we don't modify the original, 
	# and so that we can have the same backing file throughout (and 
	# thus not destroy the undoredo state by saving to a different filename).
	doc.Save(output_path + "newsletter_tmp.pdf", SDFDoc.e_incremental)

	undo_manager = doc.GetUndoManager()

	snap0 = undo_manager.TakeSnapshot()

	snap0_state = snap0.CurrentState()
	
	# Start a new page
	page = doc.PageCreate()

	
	bld = ElementBuilder()			# Used to build new Element objects
	writer = ElementWriter()		# Used to write Elements to the page
	
	page = doc.PageCreate()			# Start a new page
	writer.Begin(page)				# Begin writing to this page

	# ----------------------------------------------------------
	# Add JPEG image to the file
	img = Image.Create(doc.GetSDFDoc(), input_path + "peppers.jpg")

	element = bld.CreateImage(img, Matrix2D(200, 0, 0, 250, 50, 500))
	writer.WritePlacedElement(element)

	# Finish writing to the page
	writer.End()
	doc.PagePushBack(page)

	snap1 = undo_manager.TakeSnapshot()

	if snap1.PreviousState().Equals(snap0_state):
		print("snap1 previous state equals snap0_state; previous state is correct")
		
	snap1_state = snap1.CurrentState()

	doc.Save(output_path + "newsletter_tmp.pdf", SDFDoc.e_incremental)
	copyfile(output_path + "newsletter_tmp.pdf", output_path + "addimage.pdf")

	undo_snap = undo_manager.Undo()

	doc.Save(output_path + "newsletter_tmp.pdf", SDFDoc.e_incremental)
	copyfile(output_path + "newsletter_tmp.pdf", output_path + "addimage_undone.pdf")

	undo_snap_state = undo_snap.CurrentState()

	if undo_snap_state.Equals(snap0_state):
		print("undo_snap_state equals snap0_state; undo was successful")
		
	redo_snap = undo_manager.Redo()

	doc.Save(output_path + "newsletter_tmp.pdf", SDFDoc.e_incremental)
	copyfile(output_path + "newsletter_tmp.pdf", output_path + "addimage_redone.pdf")

	if redo_snap.PreviousState().Equals(undo_snap_state):
		print("redo_snap previous state equals undo_snap_state; previous state is correct")
	
	redo_snap_state = redo_snap.CurrentState()
	
	if redo_snap_state.Equals(snap1_state):
		print("Snap1 and redo_snap are equal; redo was successful")
	
if __name__ == '__main__':
    main()
