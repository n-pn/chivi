<script context="module" lang="ts">
  throw new Error("@migration task: Check code was safely removed (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292722)");

  // import { nvinfo_bar } from '$utils/topbar_utils'

  // export async function load({ stuff, fetch }) {
  //   const { nvinfo } = stuff
  //   const api_url = `/api/books/${nvinfo.bslug.substr(0, 8)}/+edit`
  //   const api_res = await fetch(api_url)
  //   const payload = await api_res.json()

  //   const topbar = {
  //     left: [
  //       nvinfo_bar(nvinfo, { show: 'tm' }),
  //       ['Sửa thông tin', 'pencil', { href: './+info' }],
  //     ],
  //   }

  //   Object.assign(nvinfo, payload)
  //   return { props: { nvinfo }, stuff: { topbar } }
  // }
</script>

<script lang="ts">
  throw new Error("@migration task: Add data prop (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292707)");

  import { goto } from '$app/navigation'
  import { page, session } from '$app/stores'
  import { Crumb, SIcon } from '$gui'

  import NvinfoForm from '$gui/parts/nvinfo/NvinfoForm.svelte'
  export let nvinfo: CV.Nvinfo = $page.stuff.nvinfo

  $: nv_href = `/-${nvinfo.bslug}`

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
