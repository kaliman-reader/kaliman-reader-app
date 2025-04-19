/// Returns the appropriate number of columns for a grid based on the available width
int getColumnCountForHome(double width) {
  if (width < 500) {
    return 2;
  } else if (width < 700) {
    return 3;
  } else if (width < 900) {
    return 4;
  } else if (width < 1200) {
    return 5;
  } else {
    return 6;
  }
}

int getColumnCountForSubfolder(double width) {
  if (width < 500) {
    return 3;
  } else if (width < 700) {
    return 4;
  } else if (width < 900) {
    return 5;
  } else if (width < 1200) {
    return 6;
  } else {
    return 7;
  }
}
