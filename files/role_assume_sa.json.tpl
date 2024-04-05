{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${oidc_provider_arn}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "${oidc_provider_url}:aud": "sts.amazonaws.com",
                    "${oidc_provider_url}:sub": "system:serviceaccount:${namespace}:${service_account}"
                }
            }
        }
    ]
}
