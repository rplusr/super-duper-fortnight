import Link from "next/link";

export default function Navigation() {
  return (
    <nav className="fixed top-0 left-0 right-0 z-50 bg-white border-b border-gray-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <Link href="/" className="text-2xl font-light tracking-widest">
            BOUTIQUE
          </Link>

          <div className="hidden md:flex space-x-8">
            <Link href="/shop" className="text-sm tracking-wider hover:text-gray-600 transition">
              SHOP
            </Link>
            <Link href="/shop/women" className="text-sm tracking-wider hover:text-gray-600 transition">
              WOMEN
            </Link>
            <Link href="/shop/men" className="text-sm tracking-wider hover:text-gray-600 transition">
              MEN
            </Link>
            <Link href="/shop/accessories" className="text-sm tracking-wider hover:text-gray-600 transition">
              ACCESSORIES
            </Link>
            <Link href="/admin" className="text-sm tracking-wider hover:text-gray-600 transition">
              ADMIN
            </Link>
          </div>

          <div className="flex items-center space-x-4">
            <button className="text-sm tracking-wider hover:text-gray-600 transition">
              SEARCH
            </button>
            <button className="text-sm tracking-wider hover:text-gray-600 transition">
              CART (0)
            </button>
          </div>
        </div>
      </div>
    </nav>
  );
}
