import 'package:flutter/material.dart';

import '../models/curso.dart';

class CursoCard extends StatelessWidget {
  const CursoCard({super.key, required this.curso, required this.onTap});

  final Curso curso;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: Color(0xFFE9EFEC)),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F4EE),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFF2E8065),
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    curso.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    curso.categoriaNome ?? 'Sem categoria',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: const Color(0xFF718078)),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: Color(0xFF718078),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${curso.cargaHoraria} horas',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: const Color(0xFF718078)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          curso.instrutor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFF718078)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Color(0xFF89968F)),
          ],
        ),
      ),
    ),
  );
}
