import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MiniPlayer extends StatefulWidget {
  final String? songTitle;
  final String? artistName;
  final String? albumArt;
  final bool isPlaying;
  final VoidCallback? onPlayPause;
  final VoidCallback? onTap;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const MiniPlayer({
    super.key,
    this.songTitle,
    this.artistName,
    this.albumArt,
    this.isPlaying = false,
    this.onPlayPause,
    this.onTap,
    this.onNext,
    this.onPrevious,
  });

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  double _dragDistance = 0.0;
  bool _isDragging = false;

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      _dragDistance += details.delta.dx;
      // Limitar el desplazamiento para evitar que se vaya muy lejos
      _dragDistance = _dragDistance.clamp(-100.0, 100.0);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    const double threshold =
        50.0; // Umbral mínimo para activar el cambio de canción

    if (_dragDistance.abs() > threshold) {
      if (_dragDistance > 0) {
        // Swipe hacia la derecha (izquierda a derecha) -> canción anterior
        widget.onPrevious?.call();
      } else {
        // Swipe hacia la izquierda (derecha a izquierda) -> canción siguiente
        widget.onNext?.call();
      }
    }

    // Resetear el estado del arrastre
    setState(() {
      _dragDistance = 0.0;
      _isDragging = false;
    });
  }

  void _onPanCancel() {
    setState(() {
      _dragDistance = 0.0;
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.songTitle == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onPanCancel: _onPanCancel,
      child: Container(
        height: 72,
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        decoration: BoxDecoration(
          color: context.colors.card1,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Indicadores visuales de deslizamiento (sin desplazamiento del container)
              if (_isDragging && _dragDistance.abs() > 20)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: _dragDistance > 0
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        end: _dragDistance > 0
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        colors: [
                          (_dragDistance > 0
                                  ? Colors
                                      .orange // Izquierda a derecha = anterior = naranja
                                  : Colors
                                      .green) // Derecha a izquierda = siguiente = verde
                              .withOpacity(0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.7],
                      ),
                    ),
                  ),
                ),

              // Contenido principal
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: context.colors.lightGray,
                    ),
                    child: widget.albumArt != null
                        ? Image.network(
                            widget.albumArt!,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 72,
                              height: 72,
                              color: context.colors.lightGray,
                              child: Icon(
                                Icons.music_note,
                                color: context.colors.text.withOpacity(0.4),
                                size: 24,
                              ),
                            ),
                          )
                        : Container(
                            width: 72,
                            height: 72,
                            color: context.colors.lightGray,
                            child: Icon(
                              Icons.music_note,
                              color: context.colors.text.withOpacity(0.4),
                              size: 24,
                            ),
                          ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.songTitle ?? '',
                            style: TextStyle(
                              color: context.colors.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (widget.artistName != null)
                            Text(
                              widget.artistName!,
                              style: TextStyle(
                                color: context.colors.text.withOpacity(0.65),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: widget.onPlayPause,
                      icon: Icon(
                        widget.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),

              // Iconos de indicación de gesto
              if (_isDragging && _dragDistance.abs() > 30)
                Positioned(
                  left: _dragDistance > 0 ? 20 : null,
                  right: _dragDistance < 0 ? 20 : null,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Icon(
                      _dragDistance > 0
                          ? Icons
                              .skip_previous // Izquierda a derecha = anterior
                          : Icons.skip_next, // Derecha a izquierda = siguiente
                      color: (_dragDistance > 0
                              ? Colors.orange // Anterior = naranja
                              : Colors.green) // Siguiente = verde
                          .withOpacity(((_dragDistance.abs() - 30) / 20)
                              .clamp(0.0, 0.8)),
                      size: 32,
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
