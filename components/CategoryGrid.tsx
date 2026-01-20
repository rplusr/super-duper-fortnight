import Image from "next/image";
import Link from "next/link";
import { Category } from "@/lib/cms";

interface CategoryGridProps {
  categories: Category[];
}

export default function CategoryGrid({ categories }: CategoryGridProps) {
  return (
    <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
      <h2 className="text-4xl font-light tracking-widest text-center mb-16">SHOP BY CATEGORY</h2>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {categories.map((category, index) => (
          <Link key={index} href={category.link} className="group relative h-96 overflow-hidden">
            <Image
              src={category.image}
              alt={category.name}
              fill
              className="object-cover group-hover:scale-105 transition duration-500"
            />
            <div className="absolute inset-0 bg-black bg-opacity-40 group-hover:bg-opacity-30 transition flex items-center justify-center">
              <h3 className="text-white text-3xl font-light tracking-widest">{category.name}</h3>
            </div>
          </Link>
        ))}
      </div>
    </section>
  );
}
