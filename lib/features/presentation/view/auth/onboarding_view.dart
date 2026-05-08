import 'package:flutter/material.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final baseW = 402.0;
    final baseH = 874.0;
    final scaleW = size.width / baseW;
    final scaleH = size.height / baseH;
    double sW(double v) => v * scaleW;
    double sH(double v) => v * scaleH;
    double sSp(double v) => v * ((scaleW + scaleH) / 2);

    return Scaffold(
      body: Center(
        child: Container(
          width: size.width,
          height: size.height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.50, -0.00),
              end: Alignment(0.50, 1.00),
              colors: [const Color(0xFFFCFBF7), const Color(0xFF27814B)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: sW(-269),
                top: sH(-33),
                child: Container(
                  width: sW(941),
                  height: sH(941),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/941x941"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: sW(-269),
                top: sH(-33),
                child: Container(
                  width: sW(941),
                  height: sH(941),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/941x941"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: sW(0),
                top: sH(-56),
                child: Container(
                  width: sW(402),
                  height: sH(964),
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.97, -0.00),
                      end: Alignment(-0.00, 1.00),
                      colors: [const Color(0xFF22561E), Colors.black],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sW(40)),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: sW(112),
                top: sH(238),
                child: Text(
                  'Leafy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: sSp(64),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                left: sW(38),
                top: sH(647),
                child: Container(
                  width: sW(326),
                  height: sH(56),
                  decoration: ShapeDecoration(
                    color: const Color(0xFF27814B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sW(30)),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: sW(123),
                top: sH(660),
                child: Text(
                  'Mulai Sekarang',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: sSp(20),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: sW(48),
                top: sH(733),
                child: SizedBox(
                  width: sW(306),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Dengan melanjutkan, kamu menyetujui\\n',
                          style: TextStyle(
                            color: const Color(0xFF3B7F2C),
                            fontSize: sSp(15),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: 'Privacy Policy · Terms of service',
                          style: TextStyle(
                            color: const Color(0xFF496843),
                            fontSize: sSp(15),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned(
                left: sW(50),
                top: sH(346),
                child: SizedBox(
                  width: sW(303),
                  child: Text(
                    'Deteksi kesehatan daun anda            dengan mudah',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xA8209A20),
                      fontSize: sSp(15),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
