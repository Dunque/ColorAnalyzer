class Parser {
  Result result;
  Status status;

  Parser({this.result, this.status});

  Parser.fromJson(Map<String, dynamic> json) {
    result =
    json['result'] != null ? new Result.fromJson(json['result']) : null;
    status =
    json['status'] != null ? new Status.fromJson(json['status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.result != null) {
      data['result'] = this.result.toJson();
    }
    if (this.status != null) {
      data['status'] = this.status.toJson();
    }
    return data;
  }
}

class Result {
  Colors colors;

  Result({this.colors});

  Result.fromJson(Map<String, dynamic> json) {
    colors =
    json['colors'] != null ? new Colors.fromJson(json['colors']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.colors != null) {
      data['colors'] = this.colors.toJson();
    }
    return data;
  }
}

class Colors {
  List<ColorsList> backgroundColors;
  double colorPercentThreshold;
  int colorVariance;
  List<ColorsList> foregroundColors;
  List<ColorsList> imageColors;
  double objectPercentage;

  Colors(
      {this.backgroundColors,
        this.colorPercentThreshold,
        this.colorVariance,
        this.foregroundColors,
        this.imageColors,
        this.objectPercentage});

  Colors.fromJson(Map<String, dynamic> json) {
    if (json['background_colors'] != null) {
      backgroundColors = new List<ColorsList>();
      json['background_colors'].forEach((v) {
        backgroundColors.add(new ColorsList.fromJson(v));
      });
    }
    colorPercentThreshold = json['color_percent_threshold'];
    colorVariance = json['color_variance'];
    if (json['foreground_colors'] != null) {
      foregroundColors = new List<ColorsList>();
      json['foreground_colors'].forEach((v) {
        foregroundColors.add(new ColorsList.fromJson(v));
      });
    }
    if (json['image_colors'] != null) {
      imageColors = new List<ColorsList>();
      json['image_colors'].forEach((v) {
        imageColors.add(new ColorsList.fromJson(v));
      });
    }
    objectPercentage = json['object_percentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.backgroundColors != null) {
      data['background_colors'] =
          this.backgroundColors.map((v) => v.toJson()).toList();
    }
    data['color_percent_threshold'] = this.colorPercentThreshold;
    data['color_variance'] = this.colorVariance;
    if (this.foregroundColors != null) {
      data['foreground_colors'] =
          this.foregroundColors.map((v) => v.toJson()).toList();
    }
    if (this.imageColors != null) {
      data['image_colors'] = this.imageColors.map((v) => v.toJson()).toList();
    }
    data['object_percentage'] = this.objectPercentage;
    return data;
  }
}

class ColorsList {
  int b;
  String closestPaletteColor;
  String closestPaletteColorHtmlCode;
  String closestPaletteColorParent;
  double closestPaletteDistance;
  int g;
  String htmlCode;
  double percent;
  int r;

  ColorsList(
      {this.b,
        this.closestPaletteColor,
        this.closestPaletteColorHtmlCode,
        this.closestPaletteColorParent,
        this.closestPaletteDistance,
        this.g,
        this.htmlCode,
        this.percent,
        this.r});

  ColorsList.fromJson(Map<String, dynamic> json) {
    b = json['b'];
    closestPaletteColor = json['closest_palette_color'];
    closestPaletteColorHtmlCode = json['closest_palette_color_html_code'];
    closestPaletteColorParent = json['closest_palette_color_parent'];
    closestPaletteDistance = json['closest_palette_distance'];
    g = json['g'];
    htmlCode = json['html_code'];
    percent = json['percent'];
    r = json['r'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['b'] = this.b;
    data['closest_palette_color'] = this.closestPaletteColor;
    data['closest_palette_color_html_code'] = this.closestPaletteColorHtmlCode;
    data['closest_palette_color_parent'] = this.closestPaletteColorParent;
    data['closest_palette_distance'] = this.closestPaletteDistance;
    data['g'] = this.g;
    data['html_code'] = this.htmlCode;
    data['percent'] = this.percent;
    data['r'] = this.r;
    return data;
  }
}

class Status {
  String text;
  String type;

  Status({this.text, this.type});

  Status.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    data['type'] = this.type;
    return data;
  }
}
