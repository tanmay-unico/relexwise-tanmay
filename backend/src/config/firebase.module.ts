import { DynamicModule, Module, Global } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';

@Global()
@Module({})
export class FirebaseModule {
  static forRoot(): DynamicModule {
    const firebaseProvider = {
      provide: 'FIREBASE_APP',
      useFactory: (configService: ConfigService) => {
        if (!admin.apps.length) {
          // Check if using JSON format or individual variables
          const serviceAccountJson = configService.get<string>('FIREBASE_SERVICE_ACCOUNT_JSON');
          
          if (serviceAccountJson) {
            // Parse JSON string
            const serviceAccount = JSON.parse(serviceAccountJson);
            // Fix private key formatting
            if (serviceAccount.private_key) {
              serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, '\n');
            }
            return admin.initializeApp({
              credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
            });
          } else {
            // Fallback to individual environment variables
            const privateKey = configService
              .get<string>('FIREBASE_PRIVATE_KEY')
              ?.replace(/\\n/g, '\n');

            const serviceAccount = {
              projectId: configService.get('FIREBASE_PROJECT_ID'),
              clientEmail: configService.get('FIREBASE_CLIENT_EMAIL'),
              privateKey: privateKey,
            };

            return admin.initializeApp({
              credential: admin.credential.cert(
                serviceAccount as admin.ServiceAccount,
              ),
            });
          }
        }
        return admin.app();
      },
      inject: [ConfigService],
    };

    return {
      module: FirebaseModule,
      providers: [firebaseProvider],
      exports: [firebaseProvider],
      global: true,
    };
  }
}

