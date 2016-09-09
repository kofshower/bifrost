#ifndef __PS_SE_GALILEO_MONITOR_SO_API_H__
#define __PS_SE_GALILEO_MONITOR_SO_API_H__
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
typedef void* (*reload_hook)(void *argv);
typedef struct _reload_hook_ctx
{
    void            *_arg;
    reload_hook     _func;
}reload_hook_ctx_t; 

typedef int(*GmStartApi)(const char *,const char *,const char *,const char *);
int gmstart(const char *path, const char *conf, const char *node, const char *svrlist);

/**
 * µÃµ½ÅäÖÃÏî
 *
 * @param key    ÏîÃû
 * @param value  ÏîÖµ
 * @param min    ×îÐ¡
 * @param max    ×î´ó
 * @param def    Ä¬ÈÏÖµ
 *
 * @return ÊÇ·ñ³É¹¦
 *         ==0 ³É¹¦
 *         !=0 ²»³É¹¦
 */
typedef int(*GmGetConfInt32Api)(const char *, int *, int, int, int);
int gmget_conf_int32(const char *key, int *value, int min, int max, int def);
/**
 * µÃµ½ÅäÖÃÏî
 *
 * @param key    ÏîÃû
 * @param value  ÏîÖµ
 * @param min    ×îÐ¡
 * @param max    ×î´ó
 *
 * @return ÊÇ·ñ³É¹¦
 *         ==0 ³É¹¦
 *         !=0 ²»³É¹¦
 */
typedef int(*GmGetConfUint64Api)(const char *, unsigned long long *, uint64_t, uint64_t);
int gmget_conf_uint64(const char *key, unsigned long long *value, uint64_t min, uint64_t max);
/**
 * µÃµ½ÅäÖÃÏî
 *
 * @param key    ÏîÃû
 * @param value  ÏîÖµ
 * @param min    ×îÐ¡
 * @param max    ×î´ó
 *
 * @return ÊÇ·ñ³É¹¦
 *         ==0 ³É¹¦
 *         !=0 ²»³É¹¦
 */
typedef int(*GmGetConfFloatApi)(const char *, float *, float, float);
int gmget_conf_float(const char *key, float *value, float min, float max);
/**
 * µÃµ½ÅäÖÃÏî
 *
 * @param key     ÏîÃû
 * @param dest_bufÏîÖµ
 * @param dest_lenÏî³¤
 *
 * @return ÊÇ·ñ³É¹¦
 *         ==0 ³É¹¦
 *         !=0 ²»³É¹¦
 */
typedef int(*GmGetConfNstrApi)(const char *, char *, uint32_t);
int gmget_conf_nstr(const char *key, char *dest_buf, uint32_t dest_len);

typedef void(*GmSetReloadHook)(reload_hook_ctx_t);
void gmset_reload_hook(reload_hook_ctx_t ctx);

#ifdef __cplusplus
}
#endif

#endif //__PS_SE_GALILEO_MONITOR_SO_API_H__

