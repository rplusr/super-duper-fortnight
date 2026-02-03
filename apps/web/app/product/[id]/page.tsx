import Image from "next/image";
import { getProductById } from "@/lib/cms";
import { notFound } from "next/navigation";
import CheckoutButton from "@/components/CheckoutButton";

export default function ProductPage({ params }: { params: { id: string } }) {
  const product = getProductById(params.id);

  if (!product) {
    notFound();
  }

  return (
    <div className="min-h-screen mt-16">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
          <div className="relative aspect-[3/4]">
            <Image
              src={product.image}
              alt={product.name}
              fill
              className="object-cover"
              priority
            />
          </div>

          <div className="flex flex-col justify-center">
            <p className="text-sm tracking-wider text-gray-500 mb-2">{product.category}</p>
            <h1 className="text-4xl font-light tracking-wider mb-6">{product.name}</h1>
            <p className="text-2xl tracking-wider mb-8">${product.price}</p>

            <div className="mb-8">
              <h2 className="text-lg tracking-wider mb-4">DESCRIPTION</h2>
              <p className="text-gray-600 leading-relaxed">
                Premium quality {product.category.toLowerCase()} crafted with attention to detail.
                This piece combines timeless elegance with contemporary design, perfect for any occasion.
              </p>
            </div>

            <div className="mb-8">
              <h2 className="text-lg tracking-wider mb-4">SIZE</h2>
              <div className="flex gap-2">
                {['XS', 'S', 'M', 'L', 'XL'].map((size) => (
                  <button
                    key={size}
                    className="px-4 py-2 border border-gray-300 hover:border-black transition"
                  >
                    {size}
                  </button>
                ))}
              </div>
            </div>

            <CheckoutButton
              productId={product.id}
              productName={product.name}
              price={product.price}
              imageUrl={product.image}
            />

            <div className="mt-12 pt-12 border-t border-gray-200">
              <details className="mb-4">
                <summary className="cursor-pointer text-sm tracking-wider mb-2">SHIPPING & RETURNS</summary>
                <p className="text-sm text-gray-600 mt-2">Free shipping on orders over $200. Returns accepted within 30 days.</p>
              </details>
              <details>
                <summary className="cursor-pointer text-sm tracking-wider mb-2">CARE INSTRUCTIONS</summary>
                <p className="text-sm text-gray-600 mt-2">Professional dry clean only. Store in a cool, dry place.</p>
              </details>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
