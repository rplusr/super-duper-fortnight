import fs from 'fs';
import path from 'path';

export interface HeroData {
  title: string;
  subtitle: string;
  image: string;
  ctaText: string;
  ctaLink: string;
}

export interface Product {
  id: string;
  name: string;
  price: number;
  image: string;
  category: string;
}

export interface Category {
  name: string;
  image: string;
  link: string;
}

export interface Collections {
  hero: HeroData;
  featured: Product[];
  categories: Category[];
}

export function getCollections(): Collections {
  const filePath = path.join(process.cwd(), 'cms', 'collections.json');
  const fileContents = fs.readFileSync(filePath, 'utf8');
  return JSON.parse(fileContents);
}

export function updateCollections(data: Collections): void {
  const filePath = path.join(process.cwd(), 'cms', 'collections.json');
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
}

export function getProductById(id: string): Product | undefined {
  const collections = getCollections();
  return collections.featured.find(product => product.id === id);
}
