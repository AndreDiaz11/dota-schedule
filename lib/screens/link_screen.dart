import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/group_provider.dart';

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
        appBar: AppBar(title: const Text('Vincular dispositivo')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Tu código es:'),
                const SizedBox(height: 12),
                Text(
                  _generatedCode!,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Anótalo: lo vas a necesitar para vincular tu otro dispositivo (celular o PC). Puedes verlo de nuevo en Ajustes.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go('/calendar'),
                  child: const Text('Continuar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Vincular dispositivo')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Vincula este dispositivo para sincronizar tus equipos favoritos',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _createGroup,
                  child: const Text('Crear código nuevo'),
                ),
                const SizedBox(height: 32),
                const Text('¿Ya tienes un código de otro dispositivo?'),
                const SizedBox(height: 8),
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
                OutlinedButton(
                  onPressed: _loading ? null : _joinGroup,
                  child: const Text('Vincular con este código'),
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
    );
  }
}
