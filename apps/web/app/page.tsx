import Hero from "@/components/Hero";
import FeaturedProducts from "@/components/FeaturedProducts";
import CategoryGrid from "@/components/CategoryGrid";
import { getCollections } from "@/lib/cms";

export default function Home() {
  const collections = getCollections();

  return (
    <div className="min-h-screen">
      <Hero data={collections.hero} />
      <FeaturedProducts products={collections.featured} />
      <CategoryGrid categories={collections.categories} />
    </div>
  );
}
