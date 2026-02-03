import Link from "next/link";

export default function Footer() {
  return (
    <footer className="bg-black text-white py-16 mt-24">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          <div>
            <h3 className="text-lg font-light tracking-widest mb-4">CUSTOMER SERVICE</h3>
            <ul className="space-y-2 text-sm text-gray-400">
              <li><Link href="/contact" className="hover:text-white transition">Contact Us</Link></li>
              <li><Link href="/shipping" className="hover:text-white transition">Shipping</Link></li>
              <li><Link href="/returns" className="hover:text-white transition">Returns</Link></li>
              <li><Link href="/faq" className="hover:text-white transition">FAQ</Link></li>
            </ul>
          </div>

          <div>
            <h3 className="text-lg font-light tracking-widest mb-4">ABOUT</h3>
            <ul className="space-y-2 text-sm text-gray-400">
              <li><Link href="/about" className="hover:text-white transition">Our Story</Link></li>
              <li><Link href="/sustainability" className="hover:text-white transition">Sustainability</Link></li>
              <li><Link href="/careers" className="hover:text-white transition">Careers</Link></li>
            </ul>
          </div>

          <div>
            <h3 className="text-lg font-light tracking-widest mb-4">FOLLOW US</h3>
            <ul className="space-y-2 text-sm text-gray-400">
              <li><a href="#" className="hover:text-white transition">Instagram</a></li>
              <li><a href="#" className="hover:text-white transition">Facebook</a></li>
              <li><a href="#" className="hover:text-white transition">Twitter</a></li>
              <li><a href="#" className="hover:text-white transition">Pinterest</a></li>
            </ul>
          </div>

          <div>
            <h3 className="text-lg font-light tracking-widest mb-4">NEWSLETTER</h3>
            <p className="text-sm text-gray-400 mb-4">Subscribe to receive updates, access to exclusive deals, and more.</p>
            <input
              type="email"
              placeholder="Enter your email"
              className="w-full px-4 py-2 bg-transparent border border-gray-600 text-white placeholder-gray-500 focus:outline-none focus:border-white"
            />
            <button className="w-full mt-2 px-4 py-2 bg-white text-black hover:bg-gray-200 transition">
              SUBSCRIBE
            </button>
          </div>
        </div>

        <div className="mt-12 pt-8 border-t border-gray-800 text-center text-sm text-gray-400">
          <p>&copy; 2024 BOUTIQUE. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
}
