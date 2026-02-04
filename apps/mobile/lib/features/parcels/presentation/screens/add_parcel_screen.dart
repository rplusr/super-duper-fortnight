import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/router/routes.dart';
import '../../data/models/parcel.dart';
import '../providers/parcels_provider.dart';

class AddParcelScreen extends HookConsumerWidget {
  const AddParcelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final trackingController = useTextEditingController();
    final titleController = useTextEditingController();
    final selectedCarrier = useState<CarrierType?>(null);

    final createState = ref.watch(createParcelProvider);
    final isLoading = createState.isLoading;

    ref.listen<CreateParcelState>(createParcelProvider, (previous, next) {
      if (next.createdParcel != null) {
        ref.invalidate(parcelsListProvider);
        ref.invalidate(parcelStatsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parcel added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    Future<void> handleSubmit() async {
      if (formKey.currentState?.validate() ?? false) {
        await ref.read(createParcelProvider.notifier).createParcel(
              trackingNumber: trackingController.text.trim(),
              carrier: selectedCarrier.value,
              title: titleController.text.trim().isNotEmpty
                  ? titleController.text.trim()
                  : null,
            );
      }
    }

    void openScanner() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BarcodeScannerScreen(
            onScanned: (code) {
              trackingController.text = code;
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Parcel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tracking number field with scanner button
              TextFormField(
                controller: trackingController,
                decoration: InputDecoration(
                  labelText: 'Tracking Number',
                  hintText: 'Enter or scan tracking number',
                  prefixIcon: const Icon(Icons.tag),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: openScanner,
                    tooltip: 'Scan barcode',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a tracking number';
                  }
                  if (value.length < 5) {
                    return 'Tracking number is too short';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Carrier dropdown
              DropdownButtonFormField<CarrierType?>(
                value: selectedCarrier.value,
                decoration: InputDecoration(
                  labelText: 'Carrier (Optional)',
                  hintText: 'Auto-detect carrier',
                  prefixIcon: const Icon(Icons.local_shipping_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  const DropdownMenuItem<CarrierType?>(
                    value: null,
                    child: Text('Auto-detect'),
                  ),
                  ...CarrierType.values.map(
                    (carrier) => DropdownMenuItem(
                      value: carrier,
                      child: Text(carrier.displayName),
                    ),
                  ),
                ],
                onChanged: (value) {
                  selectedCarrier.value = value;
                },
              ),
              const SizedBox(height: 16),

              // Title field
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title (Optional)',
                  hintText: 'e.g., Amazon Order, Gift from Mom',
                  prefixIcon: const Icon(Icons.label_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 24),

              // Submit button
              FilledButton(
                onPressed: isLoading ? null : handleSubmit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Track Parcel'),
              ),

              const SizedBox(height: 16),

              // Help text
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tips',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• You can scan the barcode on your package\n'
                        '• Carrier is auto-detected from the tracking number\n'
                        '• Add a title to easily identify your packages',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
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

class BarcodeScannerScreen extends StatefulWidget {
  final void Function(String code) onScanned;

  const BarcodeScannerScreen({
    super.key,
    required this.onScanned,
  });

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController? _controller;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue != null) {
      _hasScanned = true;
      widget.onScanned(barcode!.rawValue!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller!.torchState,
              builder: (context, state, child) {
                return Icon(
                  state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                );
              },
            ),
            onPressed: () => _controller?.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller?.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 280,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Text(
              'Align the barcode within the frame',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    shadows: [
                      const Shadow(
                        blurRadius: 4,
                        color: Colors.black,
                      ),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
