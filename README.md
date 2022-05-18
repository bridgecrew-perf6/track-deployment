# Track Deployment GitHub Action

> ⚠️ **Currently, this action logs to LinearB and CloudWatch. You must configure your AWS credentials first to log to CloudWatch correctly.**

## Example usage

```   
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-region: us-east-1
          aws-access-key-id: ${{ secrets.AWS_SERVICE_ACCOUNT_FEATURE_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SERVICE_ACCOUNT_FEATURE_SECRET_ACCESS_KEY }}
          mask-aws-account-id: false
      - name: Track Deployment
        if: ${{ <insert expression to evaluate if deployment should be tracked> }}
        uses: ellevation/track-deployment@main
        with:
          vendor-api-key: ${{ secrets.LINEARB_API_KEY }}
          deployment-sha: ${{ github.sha }}
          repository-url: 'https://github.com/${{ github.repository }}.git'
          environment: ${{ github.ref == 'refs/heads/main' && 'prod' || 'pre' }}
```