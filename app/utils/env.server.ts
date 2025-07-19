import { cleanEnv, str, url } from 'envalid'

export const env = cleanEnv(process.env, {
  API_URL: url(),
  GraphQL_URL: url(),
  S3_Storage_URL: url(),
  DB_URL: url(),
  Studio_URL: url(),
  Inbucket_URL: url(),
  JWT_Secret: str(),
  Anon_Key: str(),
  Service_Role_Key: str(),
  S3_Access_Key: str(),
  S3_Secret_Key: str(),
  S3_Region: str(),
})
