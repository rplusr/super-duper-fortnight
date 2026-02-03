'use client';

import { useState } from 'react';

interface CheckoutButtonProps {
  productId: string;
  productName: string;
  price: number;
  imageUrl: string;
}

export default function CheckoutButton({ productId, productName, price, imageUrl }: CheckoutButtonProps) {
  const [loading, setLoading] = useState(false);

  const handleCheckout = async () => {
    setLoading(true);

    try {
      const response = await fetch('/api/checkout', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          productId,
          productName,
          price,
          imageUrl,
        }),
      });

      const data = await response.json();

      if (data.url) {
        window.location.href = data.url;
      } else {
        alert('Failed to create checkout session');
        setLoading(false);
      }
    } catch (error) {
      console.error('Error:', error);
      alert('An error occurred. Please try again.');
      setLoading(false);
    }
  };

  return (
    <button
      onClick={handleCheckout}
      disabled={loading}
      className="w-full px-8 py-4 bg-black text-white hover:bg-gray-800 transition disabled:bg-gray-400 tracking-widest"
    >
      {loading ? 'PROCESSING...' : 'BUY NOW WITH STRIPE'}
    </button>
  );
}
