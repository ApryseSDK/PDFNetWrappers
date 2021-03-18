#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

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

	undo_manager = doc.GetUndoManager()

	# Take a snapshot to which we can undo after making changes.
	snap0 = undo_manager.TakeSnapshot()

	snap0_state = snap0.CurrentState()
	
	# Start a new page
	page = doc.PageCreate()

	bld = ElementBuilder()			# Used to build new Element objects
	writer = ElementWriter()		# Used to write Elements to the page
	writer.Begin(page)				# Begin writing to this page

	# ----------------------------------------------------------
	# Add JPEG image to the file
	img = Image.Create(doc.GetSDFDoc(), input_path + "peppers.jpg")

	element = bld.CreateImage(img, Matrix2D(200, 0, 0, 250, 50, 500))
	writer.WritePlacedElement(element)

	# Finish writing to the page
	writer.End()
	doc.PagePushFront(page)

	# Take a snapshot after making changes, so that we can redo later (after undoing first).
	snap1 = undo_manager.TakeSnapshot()

	if snap1.PreviousState().Equals(snap0_state):
		print("snap1 previous state equals snap0_state; previous state is correct")
		
	snap1_state = snap1.CurrentState()

	doc.Save(output_path + "addimage.pdf", SDFDoc.e_incremental)

	if undo_manager.CanUndo():
		undo_snap = undo_manager.Undo()

		doc.Save(output_path + "addimage_undone.pdf", SDFDoc.e_incremental)

		undo_snap_state = undo_snap.CurrentState()

		if undo_snap_state.Equals(snap0_state):
			print("undo_snap_state equals snap0_state; undo was successful")
		
		if undo_manager.CanRedo():
			redo_snap = undo_manager.Redo()

			doc.Save(output_path + "addimage_redone.pdf", SDFDoc.e_incremental)

			if redo_snap.PreviousState().Equals(undo_snap_state):
				print("redo_snap previous state equals undo_snap_state; previous state is correct")
			
			redo_snap_state = redo_snap.CurrentState()
			
			if redo_snap_state.Equals(snap1_state):
				print("Snap1 and redo_snap are equal; redo was successful")
		else:
			print("Problem encountered - cannot redo.")
	else:
		print("Problem encountered - cannot undo.")
	
if __name__ == '__main__':
    main()
