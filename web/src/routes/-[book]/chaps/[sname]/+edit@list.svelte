<script context="module" lang="ts">
  /** @type {import('./[slug]').Load} */
  export async function load({ stuff, url }) {
    const { nvinfo, nslist, nvseed } = stuff

    stuff.topbar = gen_topbar(nvinfo)
    return { props: { nvinfo, nslist, nvseed }, stuff }
  }

  function gen_topbar({ btitle_vi, bslug }) {
    return {
      left: [
        [btitle_vi, 'book', { href: `/-${bslug}`, kind: 'title' }],
        ['Tinh chỉnh', 'settings', { href: '.', show: 'pl' }],
      ],
    }
  }
</script>

<script lang="ts">
  import { page } from '$app/stores'
  import { goto } from '$app/navigation'

  import { SIcon } from '$gui'

  export let nvinfo: CV.Nvinfo
  export let nslist: CV.Nvseed[]
  export let nvseed: CV.Nvseed

  let patch_form = {
    chmin: 1,
    chmax: nslist[0].chaps,
    o_sname: nslist[0].sname,
    i_chmin: 1,
  }

  function update_patch(nvseed: CV.Nvseed) {
    patch_form.chmax = nvseed.chaps
  }

  async function submit_patch() {
    const url = `/api/seeds/${nvinfo.id}/${nvseed.sname}/patch`
    const res = await $page.stuff.api.call(url, 'PUT', patch_form)

    if (res.error) {
      alert(res.error)
      return
    }

    const pgidx = Math.floor((res.from - 1) / 128) + 1

    $page.stuff.api.uncache('nslists', nvinfo.id)
    $page.stuff.api.uncache('nvseeds', `${nvinfo.id}/${nvseed.sname}`)
    goto(`/-${nvinfo.bslug}/chaps/${nvseed.sname}?pg=${pgidx}`)
  }
</script>

<svelte:head>
  <title>Tinh chỉnh - {nvseed.sname} - {nvinfo.btitle_vi} - Chivi</title>
</svelte:head>

<article class="article">
  <h2>Tinh chỉnh nguồn truyện</h2>

  <details open>
    <summary>Thừa kế từ nguồn khác</summary>

    <div class="form-group">
      <div class="form-field">
        <label for="nvseed" class="form-label">Chọn nguồn</label>
        <select
          class="m-input"
          name="nvseed"
          id="nvseed"
          bind:value={patch_form.o_sname}>
          {#each nslist as nvseed}
            <option value={nvseed.sname} on:click={() => update_patch(nvseed)}
              >[{nvseed.sname}] ({nvseed.chaps} chương)</option>
          {/each}
        </select>
      </div>

      <div class="form-field">
        <label class="form-label" for="patch_chmin">Từ chương</label>
        <input
          type="number"
          id="patch_chmin"
          class="m-input"
          bind:value={patch_form.chmin}
          on:change={() => (patch_form.i_chmin = patch_form.chmin)} />
      </div>

      <div class="form-field">
        <label class="form-label" for="patch_chmax">Tới chương</label>
        <input
          type="number"
          id="patch_chmax"
          class="m-input"
          bind:value={patch_form.chmax} />
      </div>

      <div class="form-field">
        <label class="form-label" for="patch_i_chmin">Vị trí mới</label>
        <input
          type="number"
          id="patch_i_chmin"
          class="m-input"
          bind:value={patch_form.i_chmin} />
      </div>

      <div class="form-field _button">
        <button
          type="button"
          class="m-btn _primary _fill"
          on:click={submit_patch}>
          <SIcon name="send" />
          <span>Thực hiện</span>
        </button>
      </div>
    </div>
  </details>
</article>

<style lang="scss">
  .form-group {
    display: flex;
    gap: 0.75rem;
    align-items: flex-end;
  }

  h2 {
    margin-bottom: 1rem;
  }

  .m-input {
    height: 2rem;
    &[type='number'] {
      width: 5rem;
      text-align: center;
    }
  }

  ._button {
    margin-left: auto;
  }

  // details + details {
  //   margin-top: 1rem;
  // }

  summary {
    font-weight: 500;
    // @include ftsize(lg);
  }
</style>
