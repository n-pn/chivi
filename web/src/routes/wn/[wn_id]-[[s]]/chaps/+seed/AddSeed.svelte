<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import { goto } from '$app/navigation'
  import { api_call } from '$lib/api_call'

  export let nvinfo: CV.Wninfo

  let url = ''
  let err = ''

  $: [sname, s_bid] = extract_seed_data(url)

  async function submit() {
    err = ''

    const body = { wn_id: nvinfo.id, sname, s_bid }
    try {
      await api_call(`/_wn/seeds`, body, 'PUT')
      await goto(`/wn/${nvinfo.bslug}/chaps/${sname}`)
    } catch (ex) {
      err = ex.body.message
    }
  }

  function extract_seed_data(href: string) {
    if (!href || !href.startsWith('http')) return ['', '']

    const url = new URL(href)

    const sname = '!' + url.hostname.replace('www.', '')
    const s_bid = url.pathname.split(/\W/).filter(Boolean).pop()

    return [sname, +s_bid]
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
    <label for="s_bid" class="form-label">ID quyển sách</label>
    <input type="number" name="s_bid" class="m-input" bind:value={s_bid} />
  </div>

  <button
    class="m-btn _success _fill"
    on:click={submit}
    disabled={!sname || !s_bid}
    data-tip="Yêu cầu quyền hạn: 3">
    <span>Thêm nguồn</span>
    <SIcon name="privi-3" iset="sprite" />
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

  [name='s_bid'] {
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
