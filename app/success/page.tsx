import Link from "next/link";

export default function SuccessPage() {
  return (
    <div className="min-h-screen mt-16 flex items-center justify-center">
      <div className="text-center max-w-md mx-auto px-4">
        <div className="mb-8">
          <svg
            className="mx-auto h-16 w-16 text-green-500"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M5 13l4 4L19 7"
            />
          </svg>
        </div>
        <h1 className="text-4xl font-light tracking-widest mb-4">ORDER CONFIRMED</h1>
        <p className="text-gray-600 mb-8">
          Thank you for your purchase! You will receive an email confirmation shortly.
        </p>
        <Link
          href="/shop"
          className="inline-block px-8 py-3 bg-black text-white hover:bg-gray-800 transition tracking-widest"
        >
          CONTINUE SHOPPING
        </Link>
      </div>
    </div>
  );
}
