import Link from "next/link";
import Image from "next/image";
import { HeroData } from "@/lib/cms";

interface HeroProps {
  data: HeroData;
}

export default function Hero({ data }: HeroProps) {
  return (
    <div className="relative h-screen mt-16">
      <Image
        src={data.image}
        alt={data.title}
        fill
        className="object-cover"
        priority
      />
      <div className="absolute inset-0 bg-black bg-opacity-30 flex items-center justify-center">
        <div className="text-center text-white">
          <h2 className="text-sm tracking-widest mb-2">{data.subtitle}</h2>
          <h1 className="text-6xl md:text-8xl font-light tracking-widest mb-8">{data.title}</h1>
          <Link
            href={data.ctaLink}
            className="inline-block px-8 py-3 border-2 border-white text-white hover:bg-white hover:text-black transition tracking-widest"
          >
            {data.ctaText}
          </Link>
        </div>
      </div>
    </div>
  );
}
