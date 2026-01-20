import Image from "next/image";
import Link from "next/link";
import { getCollections } from "@/lib/cms";

export default function ShopPage() {
  const collections = getCollections();

  return (
    <div className="min-h-screen mt-16">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <h1 className="text-5xl font-light tracking-widest text-center mb-16">ALL PRODUCTS</h1>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
          {collections.featured.map((product) => (
            <Link key={product.id} href={`/product/${product.id}`} className="group">
              <div className="relative aspect-[3/4] mb-4 overflow-hidden bg-gray-100">
                <Image
                  src={product.image}
                  alt={product.name}
                  fill
                  className="object-cover group-hover:scale-105 transition duration-500"
                />
              </div>
              <div className="text-center">
                <p className="text-xs tracking-wider text-gray-500 mb-1">{product.category}</p>
                <h3 className="text-lg font-light tracking-wide mb-2">{product.name}</h3>
                <p className="text-sm tracking-wider">${product.price}</p>
              </div>
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}
