// Keywords found in typical in-car Bluetooth names (brands + car systems),
// used to pre-select the devices that are most likely a car, so users don't
// have to guess which paired device is their car.
const _carKeywords = [
  // Generic in-car Bluetooth names
  'car', 'carplay', 'uconnect', 'sync', 'mylink', 'idrive', 'mmi',
  'multimedia', 'handsfree', 'hands-free', 'bt audio',
  // Brands
  'audi', 'bmw', 'mercedes', 'benz', 'volkswagen', 'vw', 'skoda', 'škoda',
  'seat', 'cupra', 'porsche', 'opel', 'vauxhall', 'ford', 'toyota', 'lexus',
  'honda', 'acura', 'nissan', 'infiniti', 'mazda', 'mitsubishi', 'subaru',
  'suzuki', 'hyundai', 'kia', 'genesis', 'volvo', 'polestar', 'peugeot',
  'citroen', 'citroën', 'renault', 'dacia', 'fiat', 'lancia', 'alfa', 'jeep',
  'chrysler', 'dodge', 'tesla', 'mini', 'jaguar', 'land rover', 'range rover',
  'chevrolet', 'cadillac', 'gmc', 'buick', 'lincoln', 'byd', 'nio',
];

/// Whether a Bluetooth device name looks like it belongs to a car.
bool looksLikeCar(String name) {
  final n = name.toLowerCase();
  return _carKeywords.any((k) => n.contains(k));
}
