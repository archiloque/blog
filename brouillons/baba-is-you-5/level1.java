void createInitStates() {
int[] contentForState = new int[size];
for (int i = 0; i < size; i++) {
    int originalTile = originalContent[i];
    if (originalTile != 0) {
    // the bit mask is derived from the tile index
    contentForState[i] = (1 << originalTile - 1);
    }
}
addState(contentForState, new byte[0]);
}