module.exports = {
  async redirects() {
    return [
      {
        source: '/sign-in',
        destination: 'https://your-clerk-app.clerk.accounts.dev/sign-in?redirect_url=http%3A%2F%2Flocalhost%3A3002%2F', // Adjust this URL to your Clerk app domain and redirect URL
        permanent: false, // Set to false for temporary redirects
      },
    ];
  },
};

