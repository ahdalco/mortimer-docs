export default defineNuxtConfig({
  modules: ['@nuxtjs/i18n'],
  i18n: {
    defaultLocale: 'en',
    locales: [{
      code: 'en',
      name: 'English',
    }, {
      code: 'fr',
      name: 'Français',
    },{
      code: 'da',
      name: 'Danish',
    }],
  },
  content: {
    database: {
      type: 'sqlite',
      filename: '/tmp/nuxt-content.db'
    }
  },
})
