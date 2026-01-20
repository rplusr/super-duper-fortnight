# Fashion Boutique - Luxury E-Commerce Site

A modern, minimalist fashion e-commerce website inspired by high-end fashion brands like JW Anderson. Built with Next.js 14, featuring a lightweight CMS for content management and Stripe integration for secure payments.

## Features

- **Minimalist Design**: Clean, elegant interface inspired by luxury fashion brands
- **Lightweight CMS**: Easy-to-use admin panel for managing images and content without a database
- **Stripe Checkout**: Secure payment processing with Stripe
- **Responsive**: Fully responsive design that works on all devices
- **Fast Performance**: Built with Next.js 14 App Router for optimal performance
- **TypeScript**: Type-safe code for better developer experience

## Tech Stack

- **Framework**: Next.js 14 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Payment Processing**: Stripe
- **CMS**: JSON-based file system CMS
- **Images**: Next.js Image optimization with placeholder images

## Getting Started

### Prerequisites

- Node.js 18+ installed
- A Stripe account (for payment processing)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd super-duper-fortnight
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
```bash
cp .env.example .env
```

4. Add your Stripe keys to `.env`:
```env
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key
STRIPE_SECRET_KEY=sk_test_your_secret_key
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

5. Run the development server:
```bash
npm run dev
```

6. Open [http://localhost:3000](http://localhost:3000) in your browser

## Using the CMS

The CMS is a lightweight, file-based content management system that doesn't require a database.

### Accessing the Admin Panel

1. Navigate to `/admin` in your browser
2. Edit content directly in the interface
3. Click "Save Changes" to update the site

### Managing Content

All content is stored in `cms/collections.json`. You can edit:

- **Hero Section**: Main banner image, title, subtitle
- **Featured Products**: Product name, price, image, category
- **Categories**: Category name, image, and links

### Updating Images

To update images, you can:
1. Use the admin panel at `/admin` and paste new image URLs
2. Replace placeholder URLs with your own hosted images
3. Use services like:
   - Cloudinary
   - AWS S3
   - Vercel Blob Storage
   - Any public image URL

## Stripe Integration

### Setting Up Stripe

1. Create a [Stripe account](https://stripe.com)
2. Get your API keys from the Stripe Dashboard
3. Add them to your `.env` file
4. Test the checkout with Stripe's test card: `4242 4242 4242 4242`

### How It Works

- Users click "Buy Now with Stripe" on product pages
- They're redirected to Stripe's secure checkout
- After payment, they're redirected to the success page
- Stripe handles all payment processing and security

## Project Structure

```
├── app/
│   ├── admin/              # CMS admin panel
│   ├── api/
│   │   ├── checkout/       # Stripe checkout API
│   │   └── cms/            # CMS API endpoints
│   ├── product/[id]/       # Product detail pages
│   ├── shop/               # Shop listing page
│   ├── success/            # Order success page
│   ├── layout.tsx          # Root layout
│   ├── page.tsx            # Homepage
│   └── globals.css         # Global styles
├── components/             # React components
│   ├── Navigation.tsx
│   ├── Footer.tsx
│   ├── Hero.tsx
│   ├── FeaturedProducts.tsx
│   ├── CategoryGrid.tsx
│   └── CheckoutButton.tsx
├── lib/
│   ├── cms.ts              # CMS utilities
│   └── stripe.ts           # Stripe configuration
└── cms/
    └── collections.json    # CMS content data
```

## Customization

### Changing Colors

Edit `app/globals.css` and Tailwind classes in components to match your brand colors.

### Adding Products

1. Go to `/admin`
2. Add product details in the Featured Products section
3. Save changes

Or edit `cms/collections.json` directly:
```json
{
  "id": "7",
  "name": "Your Product",
  "price": 999,
  "image": "https://your-image-url.com/image.jpg",
  "category": "Category Name"
}
```

### Styling

This project uses Tailwind CSS. Modify classes in components to change styling, or update `tailwind.config.ts` for global theme changes.

## Deployment

### Deploy to Vercel

1. Push your code to GitHub
2. Import project in [Vercel](https://vercel.com)
3. Add environment variables in Vercel dashboard
4. Deploy

### Environment Variables for Production

Make sure to set these in your production environment:
- `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`
- `STRIPE_SECRET_KEY`
- `NEXT_PUBLIC_APP_URL` (your production URL)

## Development

```bash
# Run development server
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Run linter
npm run lint
```

## Security Notes

- Never commit `.env` file with real API keys
- Use Stripe test keys for development
- Enable Stripe webhook signature verification for production
- Consider adding authentication to the admin panel for production use

## Future Enhancements

- Shopping cart functionality
- User authentication
- Order history
- Product search and filtering
- Image upload functionality
- Email notifications
- Inventory management

## License

MIT

## Support

For issues and questions, please open an issue in the repository.
