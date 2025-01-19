import 'package:ebikesms/modules/global_import.dart';

class PopupMessage extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final Color backgroundColor;
  final Color textColor;

  const PopupMessage({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

  @override
  State<PopupMessage> createState() => _PopupMessageState();
}

class _PopupMessageState extends State<PopupMessage> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: ColorConstant.black,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: _expanded
            ? Row(
                children: [
                  Icon(widget.icon, color: widget.iconColor, size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: widget.textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.message,
                          style: TextStyle(
                            fontSize: 10,
                            color: widget.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: widget.backgroundColor),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            : Center(
                child: Icon(widget.icon, color: widget.iconColor, size: 40),
              ),
      ),
    );
  }
}