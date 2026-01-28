# syntax=docker/dockerfile:1

# --- build stage ---
FROM node:24.12.0-alpine AS build

# Native deps sometimes needed for npm packages
RUN apk add --no-cache python3 make g++ wget

WORKDIR /app

# install deps first for better caching
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./

# If you only use npm, this is fine. (If you use pnpm/yarn, see notes below.)
RUN npm ci

# copy rest of source
COPY . .

ENV NODE_ENV=production

# Build Nuxt for production (Nitro output in .output/)
RUN npm run build


# --- runtime stage ---
FROM node:24.12.0-alpine AS runtime

# install wget for healthcheck
RUN apk add --no-cache wget

WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000
ENV NITRO_PORT=3000
EXPOSE 3000

# copy built output + deps
COPY --from=build /app/.output ./.output
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./package.json

# Healthcheck (adjust path if you want a specific endpoint like /health)
HEALTHCHECK --interval=5s --timeout=5s --start-period=10s --retries=12 \
  CMD wget --spider -q http://127.0.0.1:3000/ || exit 1

# drop root privileges
RUN addgroup -S nodejs && adduser -S nuxt -G nodejs
USER nuxt

CMD ["node", ".output/server/index.mjs"]