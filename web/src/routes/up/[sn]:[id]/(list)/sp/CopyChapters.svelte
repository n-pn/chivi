<!-- <script lang="ts">
  // import { page } from '$app/stores'
  import { goto } from '$app/navigation'
  import { seed_path, _pgidx } from '$lib/kit_path'

  import { api_call } from '$lib/api_call'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let book_info: CV.Wninfo
  export let seed_list: { users: CV.Chroot[]; backs: CV.Chroot[] }
  export let curr_seed: CV.Chroot

  export let can_edit = false
  export let edit_url: string

  let [bg_seeds, copy_other] = init_data(seed_list, curr_seed)

  interface CopyOther {
    from_sname: string

    from_ch_no: number
    upto_ch_no: number

    base_ch_no: number
  }

  function init_data({ users = [], backs = [] }, nvseed: CV.Chroot) {
    let seeds = [...users, ...backs].filter((x) => x.sname != nvseed.sname)
    seeds = seeds.filter((x) => x.chmax > 0)

    const { chmax, sname: from_sname } = seeds[0] || { chmax: 0, sname: '' }
    const form = { from_sname, from_ch_no: 1, upto_ch_no: chmax, base_ch_no: 1 }

    return [seeds, form] as [CV.Chroot[], CopyOther]
  }

  async function submit_patch() {
    alert('Tính năng đang được hoàn thiện')
    return

    // try {
    //   await api_call(edit_url, { copy_other }, 'PATCH')
    //   const pg_no = _pgidx(copy_other.base_ch_no)
    //   const href = seed_path(book_info.bslug, curr_seed.sname, pg_no)
    //   await goto(href)
    // } catch (ex) {
    //   alert(ex.body.message)
    // }
  }

  function change_bg_seed(mirror: CV.Chroot) {
    copy_other.from_sname = mirror.sname
    copy_other.upto_ch_no = mirror.chmax
  }
</script>

<div class="form-group">
  <span class="form-field">
    <label for="mirror" class="form-label">Chọn nguồn</label>
    <select class="m-input _seed" id="mirror" value={copy_other.from_sname}>
      {#each bg_seeds as bg_seed}
        <option
          disabled={bg_seed.chmax == 0 || bg_seed.sname == curr_seed.sname}
          value={bg_seed.sname}
          on:click={() => change_bg_seed(bg_seed)}
          >[{bg_seed.sname}] ({bg_seed.chmax} chương)</option>
      {/each}
    </select>
  </span>

  <span class="group">
    <span class="form-field">
      <label class="form-label" for="from_ch_no">Từ chương</label>
      <input
        type="number"
        id="from_ch_no"
        class="m-input"
        bind:value={copy_other.from_ch_no}
        on:change={() => (copy_other.base_ch_no = copy_other.from_ch_no)} />
    </span>

    <span class="form-field">
      <label class="form-label" for="upto_ch_no">Tới chương</label>
      <input
        type="number"
        id="upto_ch_no"
        class="m-input"
        bind:value={copy_other.upto_ch_no} />
    </span>
  </span>

  <span class="group">
    <span class="form-field">
      <label class="form-label" for="base_ch_no">Vị trí mới</label>
      <input
        type="number"
        id="base_ch_no"
        class="m-input"
        bind:value={copy_other.base_ch_no} />
    </span>

    <span class="form-field _button">
      <button
        type="button"
        class="m-btn _primary _fill"
        disabled={!can_edit}
        on:click={submit_patch}>
        <SIcon name="copy" />
        <span>Sao chép</span>
      </button>
    </span>
  </span>
</div>

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

  .m-input {
    height: 2.25rem;
    &[type='number'] {
      width: 4.5rem;
      text-align: center;
    }

    &._seed {
      display: inline-block;
      min-width: 8rem;
    }
  }
</style> -->
