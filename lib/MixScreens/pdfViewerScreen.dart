import 'package:advance_pdf_viewer2/advance_pdf_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';



class PdfScreen extends StatefulWidget {
  String? url;
  String? name;
  PdfScreen({required this.url, required this.name});

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  bool _isLoading = true;
  late PDFDocument _pdf;
  late PdfViewerController _pdfViewerController;
  TextEditingController? _controller;
  final controller = ScrollController();

  void _loadFile() async {
    _pdf = await PDFDocument.fromURL(widget.url!);

    setState(() {
      _isLoading = false;
    });
  }


  @override
  void initState() {
    if (Platform.isIOS) {
      _loadFile();
    } else {
      _pdfViewerController = PdfViewerController();
      _controller = TextEditingController();
      super.initState();
    }
  }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return Platform.isIOS ? Scaffold(
        backgroundColor: Colors.white,
        body:Center(
          child: _isLoading
              ? const Center(
            child: CupertinoActivityIndicator(
              color: Color(0xFF256D85),
              radius: 20,
            ),
          )
              : SafeArea(
            child: Stack(
              children: [

                PDFViewer(
                  document: _pdf,
                  zoomSteps: 1,
                  pickerButtonColor: Color(0xFF256D85),
                ),
                Positioned(
                    top: _height * 0.03,
                    left: _width * 0.05,
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xFF256D85),
                        )))
              ],
            ),
          ),
        )

    ) : Scaffold(
      backgroundColor:  Colors.white,

      body: SafeArea(
        child: Stack(
          children: [
            SfPdfViewer.network(
              widget.url!,
              canShowPaginationDialog: true,
              controller: _pdfViewerController,
            ),
            Positioned(
                top: _height * 0.03,
                left: _width * 0.05,
                child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xFF256D85),
                    )))
          ],
        ),
      ),
      bottomNavigationBar: Card(
        elevation: 5.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.skip_previous,
                color: Colors.black54,
              ),
              onPressed: () {
                _pdfViewerController.firstPage();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black54,
              ),
              onPressed: () {
                _pdfViewerController.previousPage();
              },
            ),
            SizedBox(),
            IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                color: Colors.black54,
              ),
              onPressed: () {
                _pdfViewerController.nextPage();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.skip_next,
                color: Colors.black54,
              ),
              onPressed: () {
                _pdfViewerController.lastPage();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        //Floating action button on Scaffold
        onPressed: () {
          _displayTextInputDialog(context);
        },
        child: Icon(
          Icons.print,
          color: Colors.white,
        ),
        backgroundColor: Color(0xFF256D85),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    ) ;
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text('Search by Page Number'),
            content: TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: "eg 23"),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Color(0xFF256D85),
                textColor: const Color(0xffebf5f9),
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    _pdfViewerController
                        .jumpToPage(int.parse(_controller!.text.toString()));
                    _controller!.clear();
                    Navigator.pop(context);
                  });
                },
              ),
              MaterialButton(
                textColor: const Color(0xffebf5f9),
                color: Color(0xFF256D85),
                child: Text('Cancel'),
                onPressed: () {
                  setState(() {
                    _controller!.clear();
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }
}
