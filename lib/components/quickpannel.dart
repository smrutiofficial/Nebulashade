import 'package:flutter/material.dart';

class QuickSettingsPanel extends StatelessWidget {
  final Color Function(int) getSelectedBaseColor;

  const QuickSettingsPanel({
    super.key,
    required this.getSelectedBaseColor,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Text("hello",style: TextStyle(color: Colors.white),)
        // row bettary,setting,power,screenshort,lock screen
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            children: [
              _buildBoxBg(wsize: 60),
              Spacer(),
              _buildBoxBg(),
              SizedBox(
                width: 10,
              ),
              _buildBoxBg(),
              SizedBox(
                width: 10,
              ),
              _buildBoxBg(),
              SizedBox(
                width: 10,
              ),
              _buildBoxBg(),
            ],
          ),
        ),
        // row sound icon slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: Row(
            children: [
              Expanded(flex: 1, child: _buildBoxBg()),
              SizedBox(width: 15),
              Expanded(
                flex: 8,
                child: Stack(
                  children: [
                    _buildBoxBg(wsize: double.infinity, hsize: 15),
                    _buildBoxBg(
                        wsize: 200, hsize: 15, color: getSelectedBaseColor(4)),
                    _buildBoxBg(
                        wsize: 150, hsize: 15, color: getSelectedBaseColor(6)),
                  ],
                ),
              ),
            ],
          ),
        ),
        // row briteness slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              Expanded(flex: 1, child: _buildBoxBg()),
              SizedBox(width: 15),
              Expanded(
                flex: 8,
                child: Stack(
                  children: [
                    _buildBoxBg(wsize: double.infinity, hsize: 15),
                    _buildBoxBg(
                        wsize: 200, hsize: 15, color: getSelectedBaseColor(6)),
                  ],
                ),
              ),
            ],
          ),
        ),
        // grid wrap 2*3 button
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildBoxRow(getSelectedBaseColor(6)),
                  Spacer(),
                  _buildBoxRow(getSelectedBaseColor(6)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildBoxRow(getSelectedBaseColor(7)),
                  Spacer(),
                  _buildBoxRow(),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildBoxRow(),
                  Spacer(),
                  _buildBoxRow(getSelectedBaseColor(6)),
                ],
              ),
            ],
          ),
        )

        // pointer
      ],
    );
  }

  Widget _buildBoxRow([Color? color]) {
    return Row(
      children: [
        _buildBoxBgQuick(wsize: 120, hsize: 38, color: color),
        const SizedBox(width: 2),
        _buildBoxSideQuick(wsize: 20, hsize: 38, color: color),
      ],
    );
  }

  Widget _buildBoxSideQuick(
      {double wsize = 30, double hsize = 30, Color? color}) {
    return Container(
      width: wsize,
      height: hsize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
        color: color ?? getSelectedBaseColor(2),
      ),
    );
  }

  Widget _buildBoxBg({double wsize = 30, double hsize = 30, Color? color}) {
    return Container(
      width: wsize,
      height: hsize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: color ?? getSelectedBaseColor(2),
      ),
    );
  }

  Widget _buildBoxBgQuick(
      {double wsize = 30, double hsize = 30, Color? color}) {
    return Container(
      width: wsize,
      height: hsize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6),
          bottomLeft: Radius.circular(6),
        ),
        color: color ?? getSelectedBaseColor(2),
      ),
    );
  }
}
