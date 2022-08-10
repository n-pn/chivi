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
  export let nslist: CV.Nslist
  export let nvseed: CV.Chroot

  $: seeds = [...nslist.other, ...nslist.users]

  $: patch_form = {
    chmin: 1,
    chmax: seeds[0]?.chmax || 0,
    o_sname: seeds[0]?.sname || '',
    i_chmin: 1,
  }

  let prune = ''

  async function submit_patch() {
    const url = `/api/seeds/${nvinfo.id}/${nvseed.sname}/patch`
    const res = await $page.stuff.api.call(url, 'PUT', patch_form)

    if (res.error) return alert(res.error)
    else clean_jump(res.pgidx)
  }

  let trunc_chidx = 1

  async function trunc_source() {
    const url = `/api/seeds/${nvinfo.id}/${nvseed.sname}/trunc`
    const res = await $page.stuff.api.call(url, 'PUT', { chidx: trunc_chidx })

    if (res.error) return alert(res.error)
    else clean_jump(res.pgidx)
  }

  async function prune_source() {
    const url = `/api/seeds/${nvinfo.id}/${nvseed.sname}`
    const res = await $page.stuff.api.call(url, 'DELETE')

    if (res.error) return alert(res.error)
    else goto(`/-${nvinfo.bslug}/chaps/=base`)
  }

  function clean_jump(pgidx: number) {
    $page.stuff.api.uncache('nslists', nvinfo.id)
    $page.stuff.api.uncache('nvseeds', `${nvinfo.id}/${nvseed.sname}`)

    const root_href = `/-${nvinfo.bslug}/chaps`
    const page_href = root_href + '/' + nvseed.sname

    // invalidate(root_href)
    // invalidate(page_href)
    goto(pgidx > 1 ? `${page_href}?pg=${pgidx}` : page_href)
  }
</script>

<svelte:head>
  <title>Nguồn truyện: {nvseed.sname} - {nvinfo.btitle_vi} - Chivi</title>
</svelte:head>

<article class="article">
  <h2>Cài đặt nguồn truyện</h2>

  <details open>
    <summary>Sao chép từ nguồn khác</summary>

    <div class="form-group">
      <div class="form-field">
        <label for="nvseed" class="form-label">Chọn nguồn</label>
        <select
          class="m-input"
          name="nvseed"
          id="nvseed"
          bind:value={patch_form.o_sname}>
          {#each seeds as mirror}
            {#if mirror.chmax > 0 && mirror.sname != nvseed.sname}
              <option
                value={mirror.sname}
                on:click={() => (patch_form.chmax = mirror.chmax)}
                >[{mirror.sname}] ({mirror.chmax} chương)</option>
            {/if}
          {/each}
        </select>
      </div>

      <div class="group">
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
      </div>

      <div class="group">
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
            <SIcon name="copy" />
            <span>Sao chép</span>
          </button>
        </div>
      </div>
    </div>
  </details>

  <details open>
    <summary>Xoá chương thừa</summary>
    <div class="form-group">
      <div class="form-field">
        <label class="form-label _inline" for="trunc_chidx"
          >Xoá các chương từ vị trí</label>

        <input
          type="number"
          id="trunc_chidx"
          class="m-input"
          min="1"
          max={nvseed.chmax}
          bind:value={trunc_chidx} />
      </div>
      <div class="form-field _button">
        <button
          type="button"
          class="m-btn _warning _fill"
          on:click={trunc_source}>
          <SIcon name="cut" />
          <span>Xoá chương</span>
        </button>
      </div>
    </div>
  </details>

  <details>
    <summary>Xoá danh sách</summary>
    <div class="form-group">
      <div class="form-field">
        <label class="form-label" for="prune"
          >Gõ vào <em>{nvseed.sname}</em> để đảm bảo</label>
        <input type="text" id="prune" class="m-input" bind:value={prune} />
      </div>

      <div class="form-field _button">
        <button
          type="button"
          class="m-btn _harmful _fill"
          on:click={prune_source}
          disabled={prune != nvseed.sname}>
          <SIcon name="trash" />
          <span>Xoá danh sách</span>
        </button>
      </div>
    </div>
  </details>
</article>

<style lang="scss">
  select {
    width: 12rem;
    height: 2.25rem;
  }

  .form-group {
    display: flex;
    gap: 0.75rem;

    flex-direction: column;

    @include bp-min(ts) {
      flex-direction: row;
      align-items: flex-end;
    }
  }

  .group {
    display: flex;
    gap: 0.75rem;
    // justify-content: space-around;
    align-items: flex-end;

    .form-field {
      margin-top: 0;
    }
  }

  h2 {
    margin-bottom: 1rem;
  }

  .m-input {
    height: 2.25rem;
    &[type='number'] {
      width: 4.5rem;
      text-align: center;
    }
  }

  details + details {
    margin-top: 1rem;
  }

  summary {
    font-weight: 500;
    // @include ftsize(lg);
  }
</style>
