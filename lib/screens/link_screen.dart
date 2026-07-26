import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/group_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';

class LinkScreen extends ConsumerStatefulWidget {
  const LinkScreen({super.key});

  @override
  ConsumerState<LinkScreen> createState() => _LinkScreenState();
}

class _LinkScreenState extends ConsumerState<LinkScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _generatedCode;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).ensureSignedIn();
      final repo = ref.read(groupRepositoryProvider);
      final code = repo.generateCode();
      await repo.createGroup(code);
      await ref.read(groupStoreProvider).saveCode(code);
      ref.read(groupCodeProvider.notifier).state = code;
      await ref.read(pushServiceProvider).registerToken(code, repo);
      setState(() => _generatedCode = code);
    } catch (e) {
      setState(() => _error = 'No se pudo crear el código: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _joinGroup() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'El código debe tener 6 dígitos');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).ensureSignedIn();
      final repo = ref.read(groupRepositoryProvider);
      final exists = await repo.groupExists(code);
      if (!exists) {
        setState(() => _error = 'Ese código no existe');
        return;
      }
      await ref.read(groupStoreProvider).saveCode(code);
      ref.read(groupCodeProvider.notifier).state = code;
      await ref.read(pushServiceProvider).registerToken(code, repo);
      if (mounted) context.go('/calendar');
    } catch (e) {
      setState(() => _error = 'No se pudo vincular: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_generatedCode != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Vincular dispositivo')),
        body: _FadeIn(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: AppCard(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _Logo(),
                    const SizedBox(height: 20),
                    const Text('Tu código es:', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text(
                      _generatedCode!,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Anótalo: lo vas a necesitar para vincular tu otro dispositivo (celular o PC). Puedes verlo de nuevo en Ajustes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => context.go('/calendar'),
                        child: const Text('Continuar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Vincular dispositivo')),
      body: _FadeIn(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _Logo(),
                  const SizedBox(height: 20),
                  Text(
                    'Vincula este dispositivo para sincronizar tus equipos favoritos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _createGroup,
                      child: const Text('Crear código nuevo'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('¿Ya tienes un código de otro dispositivo?', style: TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _codeController,
                          decoration: const InputDecoration(
                            labelText: 'Código de 6 dígitos',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _loading ? null : _joinGroup,
                            child: const Text('Vincular con este código'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  if (_loading) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.sports_esports, color: AppColors.accentOnDark, size: 36),
    );
  }
}

class _FadeIn extends StatelessWidget {
  final Widget child;

  const _FadeIn({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, (1 - value) * 16), child: child),
      ),
      child: child,
    );
  }
}
