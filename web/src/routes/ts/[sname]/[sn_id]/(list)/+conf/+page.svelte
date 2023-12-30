<script lang="ts">
  import { goto } from '$app/navigation'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import { api_call } from '$lib/api_call'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import type { PageData } from './$types'
  export let data: PageData

  let slink = data.crepo.rm_slink || ''
  let pdict = data.crepo.pdict || ''
  let multp = data.crepo.multp

  $: ({ crepo } = data)
  $: action = `/_rd/tsrepos/${crepo.sroot}`

  const update_conf = async (cform: Record<string, any>) => {
    console.log({ cform })
    try {
      const res = await api_call(action, cform, 'PATCH')
      goto(data.sroot)
    } catch (ex) {
      alert(ex.body.message)
    }
  }

  const plock = {
    slink: [1, 1, 1],
    pdict: [2, 1, 2],
    multp: [3, 1, 3],
  }

  const conf_disabled = (type: string, privi: number) => {
    if (privi > 3) return false
    if (crepo.stype == 1 && crepo.owner != $_user.vu_id) return true
    return privi < plock[type][crepo.stype]
  }
</script>

<details open>
  <summary>Liên kết với nguồn nhúng ngoài</summary>

  <div class="field">
    <input
      class="m-input _sm"
      type="link"
      name="rm_slink"
      bind:value={slink}
      placeholder="Thêm nguồn mới" />

    <button
      class="m-btn _sm _primary _fill"
      disabled={!slink && conf_disabled('slink', $_user.privi)}
      on:click={() => update_conf({ slink })}>
      <SIcon name="send" />
      <span>Lưu</span>
      <SIcon name="privi-{plock.slink[crepo.stype]}" iset="icons" />
    </button>
  </div>
</details>

<details open>
  <summary>Chọn từ điển chính khi sử dụng chế độ dịch máy</summary>
  <p class="hints">
    Bạn có thể dùng từ điển riêng độc lập, hoặc dùng chung với từ điển bộ truyện
    được liên kết.
  </p>

  <div class="field options">
    <label class="radio">
      <input
        type="radio"
        value={crepo.stype == 1 ? `up${crepo.sn_id}` : 'combine'}
        bind:group={pdict} />
      <span>Dùng từ điển độc lập</span>
    </label>

    <label class="radio">
      <input
        type="radio"
        value="wn{crepo.wn_id}"
        bind:group={pdict}
        disabled={crepo.wn_id < 1} />
      <span>Dùng từ điển bộ truyện</span>
    </label>

    <button
      class="m-btn _sm _fill _success u-right"
      disabled={conf_disabled('pdict', $_user.privi)}
      on:click={() => update_conf({ pdict })}>
      <SIcon name="send" />
      <span>Lưu</span>
      <SIcon name="privi-{plock.pdict[crepo.stype]}" iset="icons" />
    </button>
  </div>
</details>

<details open>
  <summary
    >Hệ số nhân theo số lượng chữ để tính vcoin cần thiết khi mở chương</summary>
  <p class="hints">
    Tùy vào độ hiếm có, đặc dị, mức độ hoàn thiện của nội dung mà bạn có thể
    thiết đặt giá chương sao cho hợp lý
  </p>

  <div class="field options">
    {#each [1, 2, 3, 4, 5] as value}
      <label class="radio">
        <input type="radio" {value} bind:group={multp} />
        <span>{value}x</span>
      </label>
    {/each}
    <label>
      <span>Tự chọn:</span>
      <input type="number" class="m-input _sm _multp" bind:value={multp} />
    </label>

    <button
      class="m-btn _sm _fill _warning u-right"
      disabled={conf_disabled('multp', $_user.privi)}
      on:click={() => update_conf({ multp })}>
      <SIcon name="send" />
      <span>Lưu</span>
      <SIcon name="privi-{plock.multp[crepo.stype]}" iset="icons" />
    </button>
  </div>

  <p class="hints">
    Công thức tính: <code>1 vcoin / 200_000 chữ * hệ số nhân.</code>
  </p>
</details>

<style lang="scss">
  details {
    @include border(--bd-soft, $loc: bottom);
    padding-top: 0.25rem;
  }

  .field {
    @include flex-cy($gap: 0.5rem);
    margin-bottom: 0.75rem;
    input {
      flex: 1;
    }
  }

  // summary {
  //   font-weight: 500;
  //   // line-height: 2rem;
  //   @include ftsize(lg);
  //   @include fgcolor(secd);

  //   &:hover,
  //   details[open] & {
  //     @include fgcolor(primary, 5);
  //   }
  // }

  .hints {
    line-height: 1rem;
    font-style: italic;
    margin: 0.5rem 0;
    @include ftsize(sm);
    @include fgcolor(tert);
  }

  .options {
    @include flex-cy($gap: 0.5rem);
    flex-wrap: wrap;
    margin-top: 0.75rem;
  }

  .radio {
    cursor: pointer;
    display: inline-flex;
    line-height: 1.5rem;
    padding: 0.25rem 0;
    // font-weight: 500;
    input {
      margin-right: 0.25rem;
    }
  }

  .action {
    @include flex($gap: 0.75rem);
    padding: 0.75rem 0;
    justify-content: right;
  }

  ._multp {
    width: 3rem;
    padding-left: 0.25rem;
    padding-right: 0.25rem;
    text-align: center;
  }
</style>
