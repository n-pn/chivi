<script context="module">
  import { writable } from 'svelte/store'

  export async function submit_tlspec(params) {
    const url = '/api/tlspecs'
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(params),
    })

    if (res.ok) return [0, await res.json()]
    return [res.status, await res.text()]
  }

  export const state = writable(0)
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import Gmodal from '$molds/Gmodal.svelte'

  export let zhtxt = ''
  export let dname = 'combine'
  export let d_dub = 'Tổng hợp'
  export let slink = '.'

  let error
  let unote = ''
  let label = ''

  function hide_tlspec() {
    $state = 0
  }

  async function handle_submit() {
    const params = { zhtxt, dname, slink, unote, label }
    const [status, payload] = await submit_tlspec(params)
    if (status) error = payload
    else hide_tlspec()
  }

  function invalid_input(zhtxt, unote) {
    if (!zhtxt || zhtxt.length > 200) return true
    return !unote || unote.length > 500
  }
</script>

<Gmodal active={$state > 0} index={80} on_close={hide_tlspec}>
  <tlspec-wrap>
    <tlspec-head>
      <tlspec-title>Báo lỗi dịch thuật</tlspec-title>
      <button type="button" class="close-btn" on:click={hide_tlspec}>
        <SIcon name="x" />
      </button>
    </tlspec-head>

    <tlspec-body>
      <form
        action="/api/tlspecs"
        method="POSTS"
        class="tlspec-form"
        on:submit|preventDefault={handle_submit}>
        <form-group>
          <form-field>
            <label for="d_dub">Từ điển riêng (bộ truyện)</label>
            <input
              type="text"
              name="d_dub"
              class="m-input"
              disabled
              value={d_dub} />
            <input type="hidden" name="dname" value={dname} />
          </form-field>

          <form-field>
            <label for="slink">Liên kết gốc tới đoạn văn</label>

            <input
              type="text"
              name="slink"
              class="m-input"
              disabled
              bind:value={slink} />
          </form-field>
        </form-group>

        <form-group>
          <form-field>
            <label for="zhtxt">Câu văn gốc (cắt ngắn cho phù hợp)</label>
            <textarea
              class="m-input _zh"
              name="zhtxt"
              placeholder="Text tiếng trung"
              bind:value={zhtxt} />
          </form-field>
        </form-group>

        <form-group>
          <form-field>
            <label for="unote">Chú thích lỗi / gợi ý hướng giải quyết</label>

            <textarea
              class="m-input _vi"
              name="unote"
              autofocus
              bind:value={unote} />
          </form-field>
        </form-group>

        {#if error}
          <form-error>{error}</form-error>
        {/if}

        <!-- <form-group>
          <form-field>
            <label for="label">Nhãn:</label>
            <input
              type="text"
              name="label"
              class="m-input"
              placeholder="Tách nhãn bằng dấu phẩy (,)"
              bind:value={label} />
          </form-field>
        </form-group> -->

        <form-action>
          <button
            type="submit"
            class="m-btn _primary _lg _fill"
            disabled={invalid_input(zhtxt, unote)}>
            <SIcon name="send" />
            <span>Báo lỗi</span>
          </button>
        </form-action>
      </form>
    </tlspec-body>
  </tlspec-wrap>
</Gmodal>

<style lang="scss">
  tlspec-wrap {
    display: block;
    width: 28rem;
    max-width: 100%;
    padding-bottom: 0.25rem;

    @include bdradi();
    @include shadow(1);
    @include bgcolor(secd);

    @include tm-dark {
      @include linesd(--bd-soft, $ndef: false, $inset: false);
    }
  }

  $head-height: 2.25rem;

  tlspec-head {
    @include flex($gap: 0.25rem);
    padding-left: 0.75rem;
    padding-right: 0.25rem;

    height: $head-height;
    margin-bottom: 0.25rem;

    @include border(--bd-main, $loc: bottom);
    @include bdradi($loc: top);
    @include bgcolor(tert);
  }

  tlspec-title {
    flex: 1;
    text-align: center;
    line-height: $head-height;
    font-weight: 500;
  }

  .close-btn {
    padding: 0.25rem;
    @include fgcolor(tert);
    @include bgcolor(tert);

    > :global(svg) {
      width: 1.25rem;
      height: 1.25rem;
    }

    &:hover {
      @include fgcolor(primary, 6);
    }
  }

  tlspec-body {
    display: block;

    padding: 0.5rem 0.75rem;

    // @include scroll();
    @include bgcolor(secd);
  }

  form-group {
    display: flex;
    gap: 0.75rem;
    margin-bottom: 0.5rem;
  }

  form-error {
    display: block;
    line-height: 1.25rem;
    margin-top: -0.25rem;
    margin-bottom: -0.75rem;
    @include ftsize(sm);
    @include fgcolor(harmful, 5);
  }

  form-field {
    flex: 1;
    flex-basis: 100%;
  }

  textarea,
  label,
  input {
    display: block;
    width: 100%;
  }

  .m-input {
    padding-left: 0.75rem;
    padding-right: 0.75rem;
  }

  textarea {
    @include scroll();
  }

  .m-input._zh {
    @include ftsize(sm);
    height: 3rem;
    line-height: 1.25rem;
  }

  .m-input._vi {
    height: 3.5rem;
    line-height: 1.25rem;
  }

  label {
    @include ftsize(sm);
    font-weight: 500;
    margin-bottom: 0.25rem;
  }

  form-action {
    @include flex($gap: 0.75rem);
    justify-content: right;
    margin-top: 0.75rem;
  }
</style>
