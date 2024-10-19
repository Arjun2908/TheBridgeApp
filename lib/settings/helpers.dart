double getTextSize(String textSize) {
  switch (textSize) {
    case 'Small':
      return 12.0;
    case 'Medium':
      return 16.0;
    case 'Large':
      return 20.0;
    default:
      return 16.0;
  }
}

String getTextSizeString(double textSize) {
  if (textSize == 12.0) {
    return 'Small';
  } else if (textSize == 16.0) {
    return 'Medium';
  } else if (textSize == 20.0) {
    return 'Large';
  } else {
    return 'Medium';
  }
}
