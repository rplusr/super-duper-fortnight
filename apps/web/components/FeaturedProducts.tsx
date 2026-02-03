import Image from "next/image";
import Link from "next/link";
import { Product } from "@/lib/cms";

interface FeaturedProductsProps {
  products: Product[];
}

export default function FeaturedProducts({ products }: FeaturedProductsProps) {
  return (
    <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
      <h2 className="text-4xl font-light tracking-widest text-center mb-16">FEATURED COLLECTION</h2>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
        {products.map((product) => (
          <Link key={product.id} href={`/product/${product.id}`} className="group">
            <div className="relative aspect-[3/4] mb-4 overflow-hidden">
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
    </section>
  );
}
