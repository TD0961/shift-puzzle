import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        background: '#090D16',
        surface: '#0F172A',
        surfaceLight: '#1E293B',
        cardBorder: '#1E293B',
        brand: {
          DEFAULT: '#38BDF8',
          hover: '#0EA5E9',
          glow: 'rgba(56, 189, 248, 0.35)',
        },
        gold: {
          DEFAULT: '#FBBF24',
          hover: '#F59E0B',
        },
        emerald: {
          DEFAULT: '#22C55E',
        },
      },
      animation: {
        'pulse-subtle': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'float': 'float 4s ease-in-out infinite',
      },
      keyframes: {
        float: {
          '0%, 100%': { transform: 'translateY(0px)' },
          '50%': { transform: 'translateY(-8px)' },
        },
      },
    },
  },
  plugins: [],
};

export default config;
