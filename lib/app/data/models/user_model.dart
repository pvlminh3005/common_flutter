class UserModel {
  String? name;
  int? age;
  String? bio;
  String? position;
  String? job;
  String? company;
  String? address;
  bool? isPremium;
  String? avatar;

  UserModel(
      {this.name,
      this.age,
      this.bio,
      this.position,
      this.job,
      this.company,
      this.address,
      this.isPremium,
      this.avatar});

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    age = json['age'];
    bio = json['bio'];
    position = json['position'];
    job = json['job'];
    company = json['company'];
    address = json['address'];
    isPremium = json['isPremium'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['age'] = this.age;
    data['bio'] = this.bio;
    data['position'] = this.position;
    data['job'] = this.job;
    data['company'] = this.company;
    data['address'] = this.address;
    data['isPremium'] = this.isPremium;
    data['avatar'] = this.avatar;
    return data;
  }
}
