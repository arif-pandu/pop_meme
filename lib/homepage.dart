import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/services.dart' show rootBundle;

const int _tSampleRate = 44100;
const int _tNumChannels = 1;
const _bim = 'assets/sound/bim.wav';
const _bam = 'assets/sound/bam.wav';
const _boum = 'assets/sound/boum.wav';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer(logLevel: Level.debug);
  late bool _mPlayerIsInited;
  Uint8List? bimData;
  Uint8List? bamData;
  Uint8List? boumData;
  bool busy = false;
  late Image imgCat;
  late Image imgKecewa;
  Image imgCatPressed = Image.asset("assets/image/pressed.png");
  Image imgCatUnPressed = Image.asset("assets/image/unpressed.png");
  Image imgKecewaPressed = Image.asset("assets/image/kecewa pressed.png");
  Image imgKecewaUnPressed = Image.asset("assets/image/kecewa unpressed.png");

  Future<Uint8List> getAssetData(String path) async {
    var asset = await rootBundle.load(path);
    return asset.buffer.asUint8List();
  }

  Future<void> init() async {
    await _mPlayer!.openAudioSession();
    bimData = FlutterSoundHelper().waveToPCMBuffer(
      inputBuffer: await getAssetData(_bim),
    );
    bamData = FlutterSoundHelper().waveToPCMBuffer(
      inputBuffer: await getAssetData(_bam),
    );
    boumData = FlutterSoundHelper().waveToPCMBuffer(
      inputBuffer: await getAssetData(_boum),
    );
    await _mPlayer!.startPlayerFromStream(
      codec: Codec.pcm16,
      numChannels: _tNumChannels,
      sampleRate: _tSampleRate,
    );
  }

  @override
  void initState() {
    super.initState();
    init().then((value) => setState(() {
          _mPlayerIsInited = true;
        }));
    imgCat = imgCatUnPressed;
    imgKecewa = imgKecewaUnPressed;
  }

  @override
  void dispose() {
    _mPlayer!.stopPlayer();
    _mPlayer!.closeAudioSession();
    _mPlayer = null;

    super.dispose();
  }

  void play(Uint8List? data) async {
    if (!busy && _mPlayerIsInited) {
      busy = true;
      await _mPlayer!.feedFromStream(data!).then((value) => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              //
              PageView(
                children: [
                  // POP CAT
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/image/BG.jpg"),
                          fit: BoxFit.cover),
                    ),
                    child: Center(
                      child: Container(
                        height: 300,
                        width: 300,
                        color: Colors.transparent,
                        child: GestureDetector(
                          child: imgCat,
                          onTapDown: (tap) {
                            setState(() {
                              imgCat = imgCatPressed;
                              play(bimData);
                            });
                          },
                          onTapUp: (tap) {
                            setState(() {
                              imgCat = imgCatUnPressed;
                              play(bamData);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  //

                  // SHOCKED
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/image/BG.jpg"),
                          fit: BoxFit.cover),
                    ),
                    child: Center(
                      child: Container(
                        height: 300,
                        width: 300,
                        color: Colors.transparent,
                        child: GestureDetector(
                          child: imgKecewa,
                          onTapDown: (tap) {
                            setState(() {
                              imgKecewa = imgKecewaPressed;
                              play(bimData);
                            });
                          },
                          onTapUp: (tap) {
                            setState(() {
                              imgKecewa = imgKecewaUnPressed;
                              play(bamData);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment(0, -1),
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.pink[100],
                  child: Center(
                    child: Text("Ini Iklan"),
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
