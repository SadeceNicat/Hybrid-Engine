function onSpawnNote(note:Note) {
    if (note.noteType == "mom" && !note.mustPress) {
        note.animSuffix = "-alt";
    }
}