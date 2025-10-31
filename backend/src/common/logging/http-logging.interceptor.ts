import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap, catchError } from 'rxjs/operators';

@Injectable()
export class HttpLoggingInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const req = context.switchToHttp().getRequest();
    const { method, url, headers, body, query, params } = req || {};
    const start = Date.now();
    // Basic request log (avoid logging sensitive values)
    // eslint-disable-next-line no-console
    console.log('[REQ]', method, url, {
      params,
      query,
      // do not log authorization header
      hasAuthHeader: Boolean(headers?.authorization),
      bodyKeys: body ? Object.keys(body) : [],
    });

    return next.handle().pipe(
      tap((data) => {
        // eslint-disable-next-line no-console
        console.log('[RES]', method, url, {
          ms: Date.now() - start,
          status: 200,
          dataType: data?.constructor?.name || typeof data,
        });
      }),
      catchError((err, caught) => {
        // eslint-disable-next-line no-console
        console.error('[ERR]', method, url, {
          ms: Date.now() - start,
          status: err?.status || 500,
          message: err?.message,
          response: err?.response,
        });
        throw err;
      }) as any,
    );
  }
}


