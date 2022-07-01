<script lang="ts">
  import { SIcon } from '$gui'
  import { page } from '$app/stores'
  import { goto } from '$app/navigation'

  export let nvinfo: CV.Nvinfo

  let url = ''
  let err = ''

  $: [sname, snvid] = extract_nvseed(url)

  async function submit() {
    err = ''
    const url = `/api/seeds/${nvinfo.id}`
    const res = await $page.stuff.api.call(url, 'PUT', { sname, snvid })
    if (res.error) err = res.error
    else {
      goto(`/-${nvinfo.bslug}/chaps/${sname}`)
    }
  }

  function extract_nvseed(href: string) {
    if (!href || !href.startsWith('http')) return ['', '']

    const url = new URL(href)
    const name = clean_hostname(url.hostname)

    const slugs = url.pathname.slice(1).split('/')

    switch (name) {
      case '69shu':
        const snvid_69shu = slugs[0] == 'txt' ? slugs[1] : slugs[0]
        return [name, snvid_69shu.replace('.htm', '')]

      case 'uukanshu':
      case 'bxwxorg':
      case 'rengshu':
      case 'xbiquge':
      case 'hetushu':
      case 'biqugee':
      case 'ptwxz':
      case '133txt':
      case 'uuks':
        return [name, slugs[1]]

      case 'biqugse':
      case 'bqxs520':
        return [name, slugs[0]]

      case 'paoshu8':
      case '5200':
      case 'b5200':
      case 'biqu5200':
      case 'shubaow':
        return [name, slugs[0].split('_').pop()]

      case 'bxwx.io':
        return ['bxwxio', slugs[0].split('_').pop()]

      case 'duokanba':
        return ['duokan8', slugs[0].split('_').pop()]

      case 'zxcs':
        return ['zxcs_me', slugs[1]]

      default:
        err = 'Nguồn truyện chưa được hỗ trợ'
        return ['', '']
    }
  }

  function clean_hostname(host: string) {
    host = host.replace('www.', '')
    return host.replace(/\.(com|org|net|so|me|tv)$/, '')
  }
</script>

<div class="form-group">
  <div class="form-field">
    <label for="href" class="form-label">Đường dẫn nguồn truyện</label>

    <input
      type="url"
      name="href"
      class="m-input _url"
      bind:value={url}
      placeholder="https://link-to-book-index-page.com" />
  </div>

  <div class="form-field">
    <label for="sname" class="form-label">Nguồn truyện</label>
    <input type="text" name="sname" class="m-input" bind:value={sname} />
  </div>

  <div class="form-field">
    <label for="snvid" class="form-label">ID quyển sách</label>
    <input type="text" name="snvid" class="m-input" bind:value={snvid} />
  </div>

  <button
    class="m-btn _success _fill"
    on:click={submit}
    disabled={!sname || !snvid}>
    <SIcon name="folder-plus" />
    <span>Thêm nguồn</span>
  </button>
</div>

{#if err}
  <div class="form-msg _err">{err}</div>
{/if}

<style lang="scss">
  .form-group {
    flex-wrap: wrap;
    margin-top: 0.75rem;
  }

  .form-field {
    margin-top: 0;
  }

  .form-field:first-of-type {
    width: 100%;

    @include bp-min(ts) {
      flex: 1;
      width: auto;
    }
  }

  [name='sname'] {
    text-align: center;
    width: 6rem;
  }

  [name='snvid'] {
    text-align: center;
    width: 5.5rem;
  }

  [name='href'] {
    display: block;
    width: 100%;
    // max-width: 30rem;
  }

  .form-group {
    display: flex;
    gap: 0.75rem;
    align-items: flex-end;
  }
</style>
