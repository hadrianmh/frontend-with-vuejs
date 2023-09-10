# Build the Vue.js app
FROM node:14 as stage
WORKDIR app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Vue.js app with a lightweight web server
FROM nginx:stable-alpine as prod
COPY --from=stage /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]