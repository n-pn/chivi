<script context="module" lang="ts">
  export async function load({ stuff, fetch }) {
    const { nvinfo } = stuff
    const api_url = `/api/books/${nvinfo.bslug.substr(0, 8)}/detail`
    const api_res = await fetch(api_url)
    const payload = await api_res.json()

    Object.assign(nvinfo, payload)
    return { props: stuff }
  }
</script>

<script lang="ts">
  import { goto } from '$app/navigation'
  import { session } from '$app/stores'
  import { topbar } from '$lib/stores'
  import { Crumb, SIcon } from '$gui'

  import NvinfoForm from '$gui/parts/nvinfo/NvinfoForm.svelte'
  export let nvinfo: CV.Nvinfo

  $: nv_href = `/-${nvinfo.bslug}`

  $: topbar.set({
    left: [
      [nvinfo.btitle_vi, 'book', { href: nv_href, show: 'tm', kind: 'title' }],
      ['Sửa thông tin', 'pencil', { href: './edit' }],
    ],
  })

  async function delete_book() {
    const bslug = nvinfo.bslug.substring(0, 8)
    await fetch(`api/books/${bslug}/delete`, { method: 'DELETE' })
    await goto('/')
  }
</script>

<Crumb
  tree={[
    [nvinfo.btitle_vi, nv_href],
    ['Sửa thông tin', '.'],
  ]} />

<NvinfoForm {nvinfo}>
  <h1 slot="header">Sửa thông tin truyện [{nvinfo.btitle_vi}]</h1>
</NvinfoForm>

{#if $session.privi > 3}
  <footer>
    <button class="m-btn _harmful _lg" type="button" on:click={delete_book}>
      <SIcon name="trash" />
      <span class="-txt">Xoá bộ sách</span>
    </button>
  </footer>
{/if}

<style lang="scss">
  footer {
    margin-top: var(--gutter);
    @include flex-ca;
  }
</style>
