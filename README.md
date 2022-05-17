# track-deployment

Example usage

```- name: Track Deployment
        uses: ellevation/track-deployment@main
        with:
          vendor-api-key: ${{ secrets.LINEARB_API_KEY }}
          deployment-sha: ${{ github.sha }}
          repository-url: 'https://github.com/${{ github.repository }}.git'
          environment: 'pre'
```