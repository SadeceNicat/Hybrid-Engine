
function makeGhostNote(note:Note) {
	var ghost = new Note(note.strumTime, note.noteData, null, note.isSustainNote);
	ghost.noteType = 'MISSED_NOTE';
	ghost.multAlpha = note.multAlpha * 0.5;
	ghost.mustPress = note.mustPress;
	ghost.ignoreNote = true;
	ghost.blockHit = true;
	game.notes.add(ghost);
	ghost.rgbShader.r = int_desat(ghost.rgbShader.r, 0.5);
	ghost.rgbShader.g = int_desat(ghost.rgbShader.g, 0.5);
	ghost.rgbShader.b = int_desat(ghost.rgbShader.b, 0.5);
}

function goodNoteHit(note:Note) {
	if (note.rating == "bad" || note.rating == "shit") {
		makeGhostNote(note);
		game.combo = 0;
	}
}