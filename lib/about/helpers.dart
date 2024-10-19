// our medium text on this page is 24, 20, and 16. The large text is 32, 28, and 24. The small text is 16, 12, and 8.

double getHeaderTextSize(double textSize) {
  if (textSize == 12.0) {
    return 16;
  } else if (textSize == 16.0) {
    return 24;
  } else if (textSize == 20.0) {
    return 32;
  } else {
    return 24;
  }
}

double getTitleTextSize(double textSize) {
  if (textSize == 12.0) {
    return 12;
  } else if (textSize == 16.0) {
    return 20;
  } else if (textSize == 20.0) {
    return 28;
  } else {
    return 20;
  }
}

double getBodyTextSize(double textSize) {
  if (textSize == 12.0) {
    return 8;
  } else if (textSize == 16.0) {
    return 16;
  } else if (textSize == 20.0) {
    return 24;
  } else {
    return 16;
  }
}
